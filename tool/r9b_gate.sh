#!/usr/bin/env bash
# R9.b gate — THE DOGFOOD SWITCH. The next last_answer issue (agent doc
# payload changes never persist: ProjectView never wires onDocChanged) is
# fixed EXCLUSIVELY through last_answer: the operator (this script) drives
# the intents, AFM works on-device, and the fix lands through the agent-doc
# surface — no terminal for the work itself.
#
# Honest two-layer oracle:
#   in-loop check (the doc's check override): dart tool/agent_persistence_check.dart
#     — exit 1 until lib/home/project_view.dart wires the persistence;
#   verdict validation (operator, after PASS): flutter test
#     test/coding_agent/agent_doc_persistence_test.dart — the behavioral test.
#
# Permission policy: ONLY lib/home/project_view.dart is writable (deny-by-
# default everywhere else). On FAIL: one agent_task_guide escalation.
set -euo pipefail
cd "$(dirname "$0")/.."

REPO="$PWD"
LOG="${TMPDIR:-/tmp}/r9b_gate_app.log"
TASK='Make agent doc payload changes persist. The bug: ProjectView (lib/home/project_view.dart) builds AgentDocSurface without onDocChanged, so workspace/check/backend payload changes are lost on app restart. Fix: in the DocFormatIds.agent branch pass onDocChanged: context.read<OpenedProjectNotifier>().updateProject. Acceptance: dart tool/agent_persistence_check.dart must exit 0. Change ONLY lib/home/project_view.dart.'
TIMEOUT_S="${R9B_TIMEOUT_S:-1500}"

cleanup() {
  if [ -n "${APP_PID:-}" ]; then
    kill "$APP_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

rm -rf "$REPO/.dart_tool/harnessd_store"

# ── 1. Launch the debug app ───────────────────────────────────────────────
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
  echo "R9B_GATE FAIL: no VM service URI"; tail -20 "$LOG"; exit 1
fi
echo "R9B_GATE vm=$URI"

call_tool() {
  flutter-mcp-toolkit exec --name fmt_client_tool --args \
    "$(python3 -c '
import json, sys
tool, args, uri = sys.argv[1], json.loads(sys.argv[2]), sys.argv[3]
print(json.dumps({"toolName": tool, "arguments": args,
                  "connection": {"uri": uri}}))' "$1" "$2" "$URI")"
}

read_state() {
  call_tool agent_doc_state '{}' | python3 -c '
import json, sys
print(json.dumps((json.load(sys.stdin).get("data") or {}).get("parameters") or {}))'
}

state_field() {
  read_state | python3 -c "
import json, sys
print(json.dumps(json.load(sys.stdin).get('$1')))"
}

# ── 2. Create + open the dogfood doc ─────────────────────────────────────
DOC_ID=""
for _ in $(seq 1 60); do
  DOC_ID=$(call_tool agent_doc_create '{}' | python3 -c '
import json, sys
try:
  r = json.load(sys.stdin)
  print((r.get("data") or {}).get("parameters", {}).get("docId") or "")
except Exception:
  print("")' || true)
  [ -n "$DOC_ID" ] && break
  sleep 2
done
[ -n "$DOC_ID" ] || { echo "R9B_GATE FAIL: create never succeeded"; exit 1; }
echo "R9B_GATE created doc=$DOC_ID"

for _ in $(seq 1 90); do
  [ "$(state_field docId)" = "\"$DOC_ID\"" ] && break
  sleep 2
done
[ "$(state_field docId)" = "\"$DOC_ID\"" ] \
  || { echo "R9B_GATE FAIL: surface never opened"; exit 1; }

# ── 3. Bind THIS repo + the mechanical check override ────────────────────
call_tool agent_doc_bind "$(python3 -c '
import json, sys
print(json.dumps({"workspace": sys.argv[1],
                  "check": "dart tool/agent_persistence_check.dart"}))' "$REPO")" \
  | python3 -c '
import json, sys
r = json.load(sys.stdin)
print("R9B_GATE bind:", r.get("data", {}).get("message"))'
for _ in $(seq 1 15); do
  BOUND=$(state_field workspaces)
  [ "$BOUND" != "null" ] && [ "$BOUND" != "[]" ] && break
  sleep 1
done
echo "R9B_GATE bound=$BOUND check=$(state_field checkCommand)"
[ "$BOUND" != "null" ] && [ "$BOUND" != "[]" ] \
  || { echo "R9B_GATE FAIL: binding never landed"; exit 1; }

# ── 4. Delegate the issue ────────────────────────────────────────────────
call_tool agent_task_delegate "$(python3 -c '
import json, sys
print(json.dumps({"task": sys.argv[1]}))' "$TASK")" > /dev/null
echo "R9B_GATE delegated"

# ── 5. Permission loop (allow ONLY the fix file) + guide-on-FAIL ─────────
VERDICT=""
GUIDED=0
ALLOWED=0
REJECTED=0
DEADLINE=$((SECONDS + TIMEOUT_S))
while [ "$SECONDS" -lt "$DEADLINE" ]; do
  PERM=$(state_field pendingPermissionTitle || true)
  if [ "$PERM" != "null" ] && [ -n "$PERM" ]; then
    case "$PERM" in
      *project_view.dart*)
        call_tool agent_permission_answer '{"allow": true}' > /dev/null
        ALLOWED=$((ALLOWED + 1))
        echo "R9B_GATE permission ALLOWED (the fix file): $PERM"
        ;;
      *)
        call_tool agent_permission_answer '{"allow": false}' > /dev/null
        REJECTED=$((REJECTED + 1))
        echo "R9B_GATE permission REJECTED (deny-by-default): $PERM"
        ;;
    esac
    sleep 1
    continue
  fi
  RUNNING=$(state_field running || true)
  V=$(state_field verdict || true)
  if [ "$RUNNING" = "false" ] && [ "$V" != "null" ] && [ -n "$V" ]; then
    if printf '%s' "$V" | grep -q 'PASS'; then VERDICT="$V"; break; fi
    if [ "$GUIDED" -lt 1 ]; then
      GUIDED=$((GUIDED + 1))
      echo "R9B_GATE turn FAIL — guiding (escalation)"
      GUIDANCE='The acceptance check dart tool/agent_persistence_check.dart still fails. Edit ONLY lib/home/project_view.dart: in the DocFormatIds.agent branch of the switch, add onDocChanged: context.read<OpenedProjectNotifier>().updateProject to the AgentDocSurface constructor. Touch nothing else; keep the existing file structure intact.'
      call_tool agent_task_guide "$(python3 -c '
import json, sys
print(json.dumps({"guidance": sys.argv[1]}))' "$GUIDANCE")" \
        | python3 -c '
import json, sys
r = json.load(sys.stdin)
p = (r.get("data") or {}).get("parameters") or {}
print("R9B_GATE guide ok=", p.get("ok"), "—", r.get("data", {}).get("message") or "")'
      sleep 2
      continue
    fi
    VERDICT="$V"
    break
  fi
  sleep 2
done

if [ -z "$VERDICT" ]; then
  echo "R9B_GATE FAIL: no verdict within ${TIMEOUT_S}s"
  exit 1
fi

echo "R9B_GATE verdict=$VERDICT"
echo "R9B_GATE decisions: allowed=$ALLOWED rejected=$REJECTED guided=$GUIDED"
echo "R9B_GATE turnCount=$(state_field turnCount)"
echo "R9B_GATE transcript tail (spend source):"
state_field transcriptTail | python3 -c 'import sys; s=sys.stdin.read(); print(s[-900:])'

if printf '%s' "$VERDICT" | grep -q 'PASS'; then
  echo "R9B_GATE surface verdict PASS — operator validates the oracle layers:"
  dart tool/agent_persistence_check.dart
  flutter test test/coding_agent/agent_doc_persistence_test.dart
  echo "R9B_GATE PASS: verdict + mechanical check + behavioral test all green"
else
  echo "R9B_GATE recorded FAIL (failures are data — see the evidence row)"
  exit 2
fi
