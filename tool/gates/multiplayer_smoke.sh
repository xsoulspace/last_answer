#!/usr/bin/env bash
# Multiplayer T2 SMOKE gate — single REAL app (macOS), one mesh replica,
# one agent doc, presence on its channel. Runbook:
# docs/product/multiplayer-device-gates.md (T2 row); extends the
# tool/r9a_gate.sh pattern: flutter run + flutter-mcp-toolkit exec +
# cleanup traps + honest oracles (state dumps + assertions, never "it
# looked fine").
#
# Flow: launch debug app → mesh_host → agent_doc_create → agent_doc_bind
# (scratch workspace) → mesh_join_doc → assert mesh_status reflects
# hosting + presence → agent_doc_state dump archived → cleanup trap.
#
# Honest-oracle notes:
#  - Every step logs a row; every assertion reads verb JSON (data.*).
#  - Scratch workspace is a mktemp dir, DELETED after the run.
#  - DEVIATION (named): the created doc is NOT deleted at the end — no
#    agent_doc_delete verb exists yet; the scratch workspace the doc
#    pointed at is deleted, so the doc is inert. See I_report.
#  - mesh_host uses the app's own main-device path
#    (StorageBackendsNotifier.becomeMainDevice) — it enables mesh
#    replication and persists the role, which IS the main-device state.
set -euo pipefail
cd "$(dirname "$0")/../.."

LOG="${TMPDIR:-/tmp}/mp_smoke_app.log"
EVIDENCE="${TMPDIR:-/tmp}/mp_smoke_evidence"
SCRATCH_WS=""
APP_PID=""
STEPS_FILE="$EVIDENCE/steps.log"

mkdir -p "$EVIDENCE"
: > "$STEPS_FILE"

row() { # $1 status (PASS/FAIL/SKIP), $2 step name, $3 detail
  printf '%-5s %-22s %s\n' "$1" "$2" "$3" | tee -a "$STEPS_FILE"
}

fail_step() { # $1 step name, $2 detail — log + abort honestly
  row FAIL "$1" "$2"
  echo "MP_SMOKE FAIL at step: $1 — $2"
  exit 1
}

cleanup() {
  if [ -n "${APP_PID:-}" ]; then
    kill "$APP_PID" 2>/dev/null || true
  fi
  if [ -n "${SCRATCH_WS:-}" ] && [ -d "$SCRATCH_WS" ]; then
    rm -rf "$SCRATCH_WS"
  fi
  echo "MP_SMOKE evidence: $EVIDENCE"
}
trap cleanup EXIT

# ── 1. Scratch workspace (the doc binds THIS, never the repo) ────────────
SCRATCH_WS="$(mktemp -d "${TMPDIR:-/tmp}/mp_smoke_ws.XXXXXX")"
printf 'multiplayer smoke gate scratch workspace\n' > "$SCRATCH_WS/README.md"
row PASS 'scratch-ws' "$SCRATCH_WS"

# ── 2. Launch the debug app ──────────────────────────────────────────────
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
  echo "MP_SMOKE FAIL: no VM service URI within 300 s"; tail -20 "$LOG"; exit 1
fi
echo "MP_SMOKE vm=$URI"
row PASS 'launch' "vm=$URI"

# ── 3. Intent driver (r9a_gate pattern) ──────────────────────────────────
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

data_param() { # $1 raw tool output, $2 key — prints the value as JSON
  printf '%s' "$1" | python3 -c '
import json, sys
r = json.load(sys.stdin)
print(json.dumps((r.get("data") or {}).get("parameters", {}).get(sys.argv[1])))' "$2"
}

assert_true() { # $1 step, $2 raw output, $3 key, [$4 expected raw json]
  local got
  got=$(data_param "$2" "$3")
  local want="${4:-true}"
  if [ "$got" != "$want" ]; then
    fail_step "$1" "expected $3=$want, got $got"
  fi
}

# ── 4. mesh_host — the app's own main-device path ────────────────────────
HOST_OUT=$(call_tool mesh_host '{}' || true)
assert_true 'mesh_host' "$HOST_OUT" ok
assert_true 'mesh_host' "$HOST_OUT" hosting
ENDPOINT=$(data_param "$HOST_OUT" endpoint)
[ "$ENDPOINT" != "null" ] || fail_step 'mesh_host' "no endpoint advertised"
PAIRING_CODE=$(data_param "$HOST_OUT" pairingCode)
[ "$PAIRING_CODE" != "null" ] || fail_step 'mesh_host' "no pairing code"
row PASS 'mesh_host' "endpoint=$ENDPOINT pairingCode=<${#PAIRING_CODE} b64 chars>"

# ── 5. agent_doc_create (+ readiness probe, r9a pattern) ─────────────────
DOC_ID=""
for _ in $(seq 1 60); do
  OUT=$(call_tool agent_doc_create '{}' || true)
  DOC_ID=$(data_param "$OUT" docId | tr -d '"')
  [ -n "$DOC_ID" ] && [ "$DOC_ID" != "null" ] && break
  sleep 2
done
[ -n "$DOC_ID" ] && [ "$DOC_ID" != "null" ] \
  || fail_step 'agent_doc_create' 'never succeeded'
row PASS 'agent_doc_create' "docId=$DOC_ID"

for _ in $(seq 1 90); do
  OPEN_ID=$(call_tool agent_doc_state '{}' | python3 -c '
import json, sys
try:
  r = json.load(sys.stdin)
  print((r.get("data") or {}).get("parameters", {}).get("docId") or "")
except Exception:
  print("")' || true)
  [ "$OPEN_ID" = "$DOC_ID" ] && break
  sleep 2
done
[ "$OPEN_ID" = "$DOC_ID" ] \
  || fail_step 'doc-open' "surface never reported docId=$DOC_ID open (got $OPEN_ID)"
row PASS 'doc-open' "docId=$OPEN_ID"

# ── 6. agent_doc_bind (scratch workspace) ────────────────────────────────
BIND_OUT=$(call_tool agent_doc_bind "$(python3 -c '
import json, sys
print(json.dumps({"workspace": sys.argv[1]}))' "$SCRATCH_WS")" || true)
assert_true 'agent_doc_bind' "$BIND_OUT" ok
row PASS 'agent_doc_bind' "workspace=$SCRATCH_WS"

# ── 7. mesh_join_doc (defaults to the open doc) ──────────────────────────
JOIN_OUT=$(call_tool mesh_join_doc '{}' || true)
assert_true 'mesh_join_doc' "$JOIN_OUT" ok
assert_true 'mesh_join_doc' "$JOIN_OUT" docChannel "\"agent-$DOC_ID\""
JOIN_COUNT=$(data_param "$JOIN_OUT" presenceCount)
[ "$JOIN_COUNT" -ge 1 ] 2>/dev/null \
  || fail_step 'mesh_join_doc' "presenceCount=$JOIN_COUNT after join (self must fold)"
row PASS 'mesh_join_doc' "channel=agent-$DOC_ID presenceCount=$JOIN_COUNT"

# ── 8. mesh_status reflects hosting + presence (the T2 assertion) ────────
STATUS_OUT=$(call_tool mesh_status '{}' || true)
assert_true 'mesh_status' "$STATUS_OUT" ok
assert_true 'mesh_status' "$STATUS_OUT" hosting
assert_true 'mesh_status' "$STATUS_OUT" docChannel "\"agent-$DOC_ID\""
assert_true 'mesh_status' "$STATUS_OUT" presenceCount "$JOIN_COUNT"
row PASS 'mesh_status' "$(printf '%s' "$STATUS_OUT" | python3 -c '
import json, sys
r = json.load(sys.stdin)
p = (r.get("data") or {}).get("parameters", {})
print("hosting=%s connected=%s endpoint=%s peers=%s presence=%s" % (
  p.get("hosting"), p.get("connected"),
  p.get("endpoint"), p.get("peerCount"), p.get("presenceCount")))')"

# ── 9. One sync cycle (fires onSyncCycle → the open surface re-reads
#      the fold and rebuilds, so the CACHED debugState projection the
#      dump oracle reads is fresh, not build-time stale) ─────────────────
SYNC_OUT=$(call_tool storage_mesh_sync '{}' || true)
row PASS 'sync-cycle' "storage_mesh_sync ok=$(data_param "$SYNC_OUT" ok)"

# ── 10. Honest state dump archived (evidence, never a screenshot) ────────
STATE_OUT=$(call_tool agent_doc_state '{}' || true)
printf '%s\n' "$STATE_OUT" | python3 -c '
import json, sys
r = json.load(sys.stdin)
print(json.dumps((r.get("data") or {}).get("parameters", {}), indent=2))' \
  > "$EVIDENCE/agent_doc_state.json"
python3 - "$DOC_ID" "$EVIDENCE/agent_doc_state.json" <<'PYEOF'
import json, sys
doc_id, path = sys.argv[1], sys.argv[2]
with open(path) as f:
    state = json.load(f)
assert state.get('docId') == doc_id, f'docId mismatch: {state.get("docId")}'
assert state.get('workspaces'), 'workspace binding never landed in the payload'
mesh = state.get('meshStatus') or {}
assert mesh.get('hosting') is True, f'meshStatus.hosting={mesh.get("hosting")}'
assert (mesh.get('presenceCount') or 0) >= 1, (
    f'meshStatus.presenceCount={mesh.get("presenceCount")}')
print('agent_doc_state oracle: docId + workspaces + meshStatus OK')
PYEOF
row PASS 'state-dump' "$EVIDENCE/agent_doc_state.json"

# ── 11. mesh_leave_doc (leave frame sent; presence drops) ────────────────
LEAVE_OUT=$(call_tool mesh_leave_doc '{}' || true)
assert_true 'mesh_leave_doc' "$LEAVE_OUT" ok
STATUS2_OUT=$(call_tool mesh_status '{}' || true)
assert_true 'mesh_leave_doc' "$STATUS2_OUT" presenceCount 0
row PASS 'mesh_leave_doc' 'leave frame sent; presenceCount back to 0'

row PASS 'verdict' 'T2 smoke: hosting + doc channel presence + state dump all asserted'
echo "MP_SMOKE PASS"
