#!/usr/bin/env bash
# R9.a gate — the headless operator cycle through last_answer's OWN intents.
#
# create → bind (this repo + fixture check) → delegate → answer the
# permission → read the verdict. ZERO GUI clicks, ZERO field fills — every
# verb is `flutter-mcp-toolkit exec --name fmt_client_tool --toolName
# agent_*` against the running debug app (the agent-friendly projection of
# the same typed state the human screen renders).
#
# Honest oracle: tool/agent_fixture/main.dart throws until the agent acts;
# the fixture is RESTORED after the run (never trivially green — R5).
# Backend: apple_foundation_afm (on-device, the real-work default).
# Requires macOS 26+ with Apple Intelligence enabled.
set -euo pipefail
cd "$(dirname "$0")/.."

REPO="$PWD"
LOG="${TMPDIR:-/tmp}/r9a_gate_app.log"
TASK='Fix tool/agent_fixture/main.dart so `dart tool/agent_fixture/main.dart` exits 0: make main print ok instead of throwing. Read the file first, then edit it.'
TIMEOUT_S="${R9A_TIMEOUT_S:-900}"

restore_fixture() {
  git checkout -- tool/agent_fixture/main.dart 2>/dev/null || true
}
cleanup() {
  restore_fixture
  if [ -n "${APP_PID:-}" ]; then
    kill "$APP_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# The per-workspace world store is derived cache; a stale goal leaks old
# context into the run (measured, Phase 1). Wipe before delegating.
rm -rf "$REPO/.dart_tool/harnessd_store"
restore_fixture

# ── 1. Launch the debug app (bundled AFM bridge dylib — no env vars) ──────
: > "$LOG"
flutter run -d macos --debug > "$LOG" 2>&1 &
APP_PID=$!

URI=""
for _ in $(seq 1 150); do
  URI=$(grep -o 'ws://127.0.0.1:[0-9]*/[A-Za-z0-9_=/+-]*/ws' "$LOG" | head -1 || true)
  [ -n "$URI" ] && break
  sleep 2
done
if [ -z "$URI" ]; then
  echo "R9A_GATE FAIL: no VM service URI within 300 s"; tail -20 "$LOG"; exit 1
fi
echo "R9A_GATE vm=$URI"

# ── 2. Intent driver ──────────────────────────────────────────────────────
call_tool() { # $1 toolName, $2 arguments (JSON object)
  flutter-mcp-toolkit exec --name fmt_client_tool --args \
    "$(python3 -c '
import json, sys
tool, args, uri = sys.argv[1], json.loads(sys.argv[2]), sys.argv[3]
print(json.dumps({
  "toolName": tool, "arguments": args,
  "connection": {"uri": uri},
}))' "$1" "$2" "$URI")"
}

read_state() { # prints agent_doc_state parameters JSON
  call_tool agent_doc_state '{}' | python3 -c '
import json, sys
r = json.load(sys.stdin)
params = (r.get("data") or {}).get("parameters") or {}
print(json.dumps(params))'
}

state_field() { # $1 field — prints its JSON value
  read_state | python3 -c "
import json, sys
print(json.dumps(json.load(sys.stdin).get('$1')))"
}

# ── 3. CREATE (also the readiness probe: the hook lives on the home shell)
DOC_ID=""
for _ in $(seq 1 60); do
  OUT=$(call_tool agent_doc_create '{}' || true)
  DOC_ID=$(printf '%s' "$OUT" | python3 -c '
import json, sys
try:
  r = json.load(sys.stdin)
  print((r.get("data") or {}).get("parameters", {}).get("docId") or "")
except Exception:
  print("")' || true)
  [ -n "$DOC_ID" ] && break
  sleep 2
done
if [ -z "$DOC_ID" ]; then
  echo "R9A_GATE FAIL: agent_doc_create never succeeded"; tail -30 "$LOG"; exit 1
fi
echo "R9A_GATE created doc=$DOC_ID"

# ── 4. Wait until the new doc surface is OPEN (route push + first mount
#      can lag tens of seconds on a cold debug build — measured) ─────────
for _ in $(seq 1 90); do
  OPEN_ID=$(state_field docId || true)
  [ "$OPEN_ID" = "\"$DOC_ID\"" ] && break
  sleep 2
done
echo "R9A_GATE open docId=$(state_field docId)"
OPEN_ID=$(state_field docId || true)
if [ "$OPEN_ID" != "\"$DOC_ID\"" ]; then
  echo "R9A_GATE FAIL: the created doc surface never reported itself open"
  exit 1
fi

# ── 5. BIND this repo + the fixture check (intent — never a form fill) ────
call_tool agent_doc_bind "$(python3 -c '
import json, sys
print(json.dumps({
  "workspace": sys.argv[1],
  "check": "dart tool/agent_fixture/main.dart",
}))' "$REPO")" | python3 -c '
import json, sys
r = json.load(sys.stdin)
p = (r.get("data") or {}).get("parameters") or {}
print("R9A_GATE bind ok=", p.get("ok"), "—", r.get("data", {}).get("message") or p.get("message") or "")'
BOUND=""
for _ in $(seq 1 15); do
  BOUND=$(state_field workspaces || true)
  [ "$BOUND" != "null" ] && [ "$BOUND" != "[]" ] && break
  sleep 1
done
echo "R9A_GATE bound workspaces=$BOUND"
echo "R9A_GATE check override=$(state_field checkCommand)"
if [ "$BOUND" = "null" ] || [ "$BOUND" = "[]" ]; then
  echo "R9A_GATE FAIL: binding never landed in the doc payload"; exit 1
fi

# ── 6. DELEGATE the task sentence ────────────────────────────────────────
call_tool agent_task_delegate "$(python3 -c '
import json, sys
print(json.dumps({"task": sys.argv[1]}))' "$TASK")" \
  | python3 -c '
import json, sys
r = json.load(sys.stdin)
p = (r.get("data") or {}).get("parameters") or {}
print("R9A_GATE delegate ok=", p.get("ok"))'

# ── 7. Permission loop: allow ONLY fixture-path writes (deny-by-default),
#      read the verdict when the turn ends; on FAIL, guide once via
#      agent_task_guide (the R9.a/R9.d escalation path) and continue. ────
VERDICT=""
GUIDED=0
DEADLINE=$((SECONDS + TIMEOUT_S))
ALLOWED=0
REJECTED=0
while [ "$SECONDS" -lt "$DEADLINE" ]; do
  PERM=$(state_field pendingPermissionTitle || true)
  if [ "$PERM" != "null" ] && [ -n "$PERM" ]; then
    case "$PERM" in
      *agent_fixture*)
        call_tool agent_permission_answer '{"allow": true}' > /dev/null
        ALLOWED=$((ALLOWED + 1))
        echo "R9A_GATE permission ALLOWED (fixture path): $PERM"
        ;;
      *)
        call_tool agent_permission_answer '{"allow": false}' > /dev/null
        REJECTED=$((REJECTED + 1))
        echo "R9A_GATE permission REJECTED (deny-by-default): $PERM"
        ;;
    esac
    sleep 1
    continue
  fi
  RUNNING=$(state_field running || true)
  V=$(state_field verdict || true)
  if [ "$RUNNING" = "false" ] && [ "$V" != "null" ] && [ -n "$V" ]; then
    if printf '%s' "$V" | grep -q 'PASS'; then
      VERDICT="$V"
      break
    fi
    if [ "$GUIDED" -lt 2 ]; then
      GUIDED=$((GUIDED + 1))
      echo "R9A_GATE turn ended FAIL — guiding (escalation $GUIDED)"
      call_tool agent_task_guide "$(python3 -c '
import json
print(json.dumps({"guidance": "ONLY tool/agent_fixture/main.dart may change. "
  "Its main() must print ok and exit 0 — replace the throw with a print, "
  "change nothing else, never touch lib/ or docs/."}))')" | python3 -c '
import json, sys
r = json.load(sys.stdin)
p = (r.get("data") or {}).get("parameters") or {}
print("R9A_GATE guide ok=", p.get("ok"), "—", r.get("data", {}).get("message") or "")'
      sleep 2
      continue
    fi
    VERDICT="$V"
    break
  fi
  sleep 2
done

if [ -z "$VERDICT" ]; then
  echo "R9A_GATE FAIL: no verdict within ${TIMEOUT_S}s"
  echo "R9A_GATE last transcript tail: $(state_field transcriptTail | head -c 1500)"
  exit 1
fi

echo "R9A_GATE verdict=$VERDICT"
echo "R9A_GATE decisions: allowed=$ALLOWED rejected=$REJECTED guided=$GUIDED (denies are the safe default, never dropped)"
echo "R9A_GATE turnCount=$(state_field turnCount)"
echo "R9A_GATE guidance on grid: $(state_field lastGuidance | head -c 160)"
echo "R9A_GATE transcript tail (spend source):"
state_field transcriptTail | python3 -c 'import sys; s=sys.stdin.read(); print(s[-1200:])'

# ── 8. Mechanical oracle (the surface verdict is cross-checked) ──────────
if printf '%s' "$VERDICT" | grep -q 'PASS'; then
  dart run tool/agent_fixture/main.dart > /dev/null 2>&1 || true
  if dart tool/agent_fixture/main.dart > /dev/null 2>&1; then
    echo "R9A_GATE PASS: verdict PASS + fixture oracle exit 0 (restore follows)"
  else
    echo "R9A_GATE FAIL: verdict PASS but the fixture oracle does not exit 0"
    exit 1
  fi
else
  echo "R9A_GATE recorded FAIL (failures are data — see the evidence row)"
  exit 2
fi
