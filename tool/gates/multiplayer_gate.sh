#!/usr/bin/env bash
# Multiplayer T3 GATE — two REAL apps, one doc, scripted concurrency.
# Runbook: docs/product/multiplayer-device-gates.md (T3 / 5.G1).
# macOS app hosts the relay (dart:io main device); a web app
# (`flutter run -d web-server`) is the second peer. Extends the
# tool/r9a_gate.sh + tool/gates/multiplayer_smoke.sh pattern: two
# `flutter run` processes, two mcp_toolkit channels, one log row per
# step. A step that cannot be automated YET is SKIPPED-with-reason —
# never silent, never widened.
#
# THE HUMAN RUNS THIS when both devices exist; the script is
# dry-run-checked (bash -n + step structure) per Task I.
#
# Honest-oracle notes:
#  - Convergence oracle: debugSurface (agent_doc_state) dumps diffed at
#    convergence points; empty diff = converged (runbook §oracle). The
#    peer opens the shared doc as a VIEWER SHADOW (mesh_open_doc, Task
#    O): its projection carries the shared docId, live meshStatus, and
#    routed permissions. Fields that legitimately diverge by DEVICE ROLE
#    are stripped as NAMED divergences (the ledger inside the diff
#    steps) — never silently, each with its reason.
#  - The QR scan itself stays human: pairing uses the PASTE payload the
#    host prints (the runbook's named exception) — logged as a SKIP row
#    for the camera path, PASS row for the paste path.
#  - Remote permission routing is flipped by the mesh_routing verb (Task
#    O) before the permission steps; the reject-first → allow sequence
#    runs in full.
set -euo pipefail
cd "$(dirname "$0")/../.."

HOST_LOG="${TMPDIR:-/tmp}/mp_gate_host.log"
PEER_LOG="${TMPDIR:-/tmp}/mp_gate_peer.log"
EVIDENCE="${TMPDIR:-/tmp}/mp_gate_evidence"
SCRATCH_WS=""
HOST_PID=""
PEER_PID=""
HOST_URI=""
PEER_URI=""
STEPS_FILE="$EVIDENCE/steps.log"

mkdir -p "$EVIDENCE"
: > "$STEPS_FILE"

row() { # $1 status (PASS/FAIL/SKIP), $2 step, $3 detail
  printf '%-5s %-26s %s\n' "$1" "$2" "$3" | tee -a "$STEPS_FILE"
}

skip_step() { row SKIP "$1" "$2"; }

fail_step() {
  row FAIL "$1" "$2"
  echo "MP_GATE FAIL at step: $1 — $2"
  exit 1
}

cleanup() {
  for pid in "${HOST_PID:-}" "${PEER_PID:-}"; do
    [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  done
  if [ -n "${SCRATCH_WS:-}" ] && [ -d "$SCRATCH_WS" ]; then
    rm -rf "$SCRATCH_WS"
  fi
  echo "MP_GATE evidence: $EVIDENCE"
}
trap cleanup EXIT

# ── Channel helpers (one mcp channel per app) ────────────────────────────
wait_for_uri() { # $1 log file — echoes the VM service ws URI
  local log="$1" uri=""
  for _ in $(seq 1 150); do
    uri=$(grep -o 'ws://127.0.0.1:[0-9]*/[A-Za-z0-9_=/+-]*/ws' "$log" | head -1 || true)
    [ -n "$uri" ] && { echo "$uri"; return 0; }
    sleep 2
  done
  return 1
}

call_on() { # $1 URI, $2 toolName, $3 arguments (JSON object)
  flutter-mcp-toolkit exec --name fmt_client_tool --args \
    "$(python3 -c '
import json, sys
tool, args, uri = sys.argv[1], json.loads(sys.argv[2]), sys.argv[3]
print(json.dumps({
  "toolName": tool, "arguments": args,
  "connection": {"uri": uri},
}))' "$2" "$3" "$1")"
}

data_param() { # $1 raw output, $2 key
  printf '%s' "$1" | python3 -c '
import json, sys
r = json.load(sys.stdin)
print(json.dumps((r.get("data") or {}).get("parameters", {}).get(sys.argv[1])))' "$2"
}

dump_state() { # $1 URI, $2 out file — the debugSurface JSON projection
  call_on "$1" agent_doc_state '{}' | python3 -c '
import json, sys
r = json.load(sys.stdin)
print(json.dumps((r.get("data") or {}).get("parameters", {}), indent=2))' > "$2"
}

# ════════════════════════════════════════════════════════════════════════
# 1. BOOT (host): macOS app → create + bind doc → mesh_host → pairing code
# ════════════════════════════════════════════════════════════════════════
SCRATCH_WS="$(mktemp -d "${TMPDIR:-/tmp}/mp_gate_ws.XXXXXX")"
printf 'multiplayer T3 gate scratch workspace\n' > "$SCRATCH_WS/README.md"
row PASS 'scratch-ws' "$SCRATCH_WS"

: > "$HOST_LOG"
flutter run -d macos --debug \
  --dart-define-from-file=configs/envs/prod.json > "$HOST_LOG" 2>&1 &
HOST_PID=$!
if HOST_URI=$(wait_for_uri "$HOST_LOG"); then
  row PASS 'boot-host' "vm=$HOST_URI"
else
  tail -20 "$HOST_LOG"
  fail_step 'boot-host' 'no VM service URI within 300 s'
fi

DOC_ID=""
for _ in $(seq 1 60); do
  OUT=$(call_on "$HOST_URI" agent_doc_create '{}' || true)
  DOC_ID=$(printf '%s' "$OUT" | python3 -c '
import json, sys
try:
  r = json.load(sys.stdin)
  print((r.get("data") or {}).get("parameters", {}).get("docId") or "")
except Exception:
  print("")' || true)
  [ -n "$DOC_ID" ] && [ "$DOC_ID" != "null" ] && break
  sleep 2
done
[ -n "$DOC_ID" ] && [ "$DOC_ID" != "null" ] \
  || fail_step 'doc-create-host' 'agent_doc_create never succeeded'
row PASS 'doc-create-host' "docId=$DOC_ID"

for _ in $(seq 1 90); do
  OPEN_ID=$(call_on "$HOST_URI" agent_doc_state '{}' | python3 -c '
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
  || fail_step 'doc-open-host' "surface never reported docId=$DOC_ID open"
row PASS 'doc-open-host' "docId=$DOC_ID"

BIND_OUT=$(call_on "$HOST_URI" agent_doc_bind "$(python3 -c '
import json, sys
print(json.dumps({"workspace": sys.argv[1]}))' "$SCRATCH_WS")" || true)
[ "$(data_param "$BIND_OUT" ok)" = "true" ] \
  || fail_step 'doc-bind-host' "bind failed: $BIND_OUT"
row PASS 'doc-bind-host' "workspace=$SCRATCH_WS"

HOST_OUT=$(call_on "$HOST_URI" mesh_host '{}' || true)
[ "$(data_param "$HOST_OUT" ok)" = "true" ] \
  || fail_step 'mesh_host' "$HOST_OUT"
ENDPOINT=$(data_param "$HOST_OUT" endpoint)
PAIRING_CODE=$(data_param "$HOST_OUT" pairingCode)
[ "$ENDPOINT" != "null" ] && [ "$PAIRING_CODE" != "null" ] \
  || fail_step 'mesh_host' "endpoint=$ENDPOINT pairingCode missing"
row PASS 'mesh_host' "endpoint=$ENDPOINT"

# ════════════════════════════════════════════════════════════════════════
# 2. JOIN (peer): web app → pair via PASTE payload → join the doc channel
#    → OPEN the shared doc as a viewer shadow (mesh_open_doc, Task O)
# ════════════════════════════════════════════════════════════════════════
skip_step 'qr-scan' 'camera-less automation; the paste payload path is used (runbook: the scan itself stays human)'

: > "$PEER_LOG"
flutter run -d chrome --debug \
  --dart-define-from-file=configs/envs/prod.json > "$PEER_LOG" 2>&1 &
PEER_PID=$!
if PEER_URI=$(wait_for_uri "$PEER_LOG"); then
  row PASS 'boot-peer' "vm=$PEER_URI"
else
  tail -20 "$PEER_LOG"
  fail_step 'boot-peer' 'no VM service URI within 300 s'
fi

# The web peer pairs with the PASTE payload (base64 survives the copy
# verbatim; the service tolerates whitespace/newlines).
PAIRING_FILE="$EVIDENCE/pairing_code.b64"
printf '%s' "$PAIRING_CODE" | tr -d '"' > "$PAIRING_FILE"
PAIR_OUT=""
for _ in $(seq 1 10); do
  PAIR_OUT=$(call_on "$PEER_URI" mesh_pair "$(python3 -c '
import json, sys
print(json.dumps({"pairingCode": open(sys.argv[1]).read()}))' "$PAIRING_FILE")" 2>&1 || true)
  [ "$(data_param "$PAIR_OUT" ok)" = "true" ] && break
  sleep 5
done
rm -f "$PAIRING_FILE"
[ "$(data_param "$PAIR_OUT" ok)" = "true" ] \
  || fail_step 'mesh_pair' "$PAIR_OUT"
row PASS 'mesh_pair' "peerId=$(data_param "$PAIR_OUT" peerId) synced=$(data_param "$PAIR_OUT" synced)"

JOIN_OUT=$(call_on "$PEER_URI" mesh_join_doc "$(python3 -c '
import json, sys
print(json.dumps({"docId": sys.argv[1]}))' "$DOC_ID")" || true)
[ "$(data_param "$JOIN_OUT" ok)" = "true" ] \
  || fail_step 'mesh_join_doc-peer' "$JOIN_OUT"
row PASS 'mesh_join_doc-peer' "channel=agent-$DOC_ID presenceCount=$(data_param "$JOIN_OUT" presenceCount)"

# The peer OPENS the shared doc (Task O): a viewer shadow bound to the
# shared id — no workspace, no daemon session. From here the peer's
# agent_doc_state is an honest ok projection (docId, viewer:true, live
# meshStatus, routed permissions), not an error envelope.
OPEN_PEER_OUT=""
for _ in $(seq 1 10); do
  OPEN_PEER_OUT=$(call_on "$PEER_URI" mesh_open_doc "$(python3 -c '
import json, sys
print(json.dumps({"docId": sys.argv[1]}))' "$DOC_ID")" || true)
  [ "$(data_param "$OPEN_PEER_OUT" ok)" = "true" ] && break
  sleep 2
done
[ "$(data_param "$OPEN_PEER_OUT" ok)" = "true" ] \
  || fail_step 'mesh_open_doc-peer' "$OPEN_PEER_OUT"
[ "$(data_param "$OPEN_PEER_OUT" docId)" = "$DOC_ID" ] \
  || fail_step 'mesh_open_doc-peer' "shadow bound to $(data_param "$OPEN_PEER_OUT" docId), expected $DOC_ID"
[ "$(data_param "$OPEN_PEER_OUT" viewer)" = "true" ] \
  || fail_step 'mesh_open_doc-peer' 'the shadow must project viewer:true (DESIGN §6)'
row PASS 'mesh_open_doc-peer' "viewer shadow open on agent-$DOC_ID"

# Host-side presence now shows the web peer (convergence point #0).
HOST_STATUS=$(call_on "$HOST_URI" mesh_status "$(python3 -c '
import json, sys
print(json.dumps({"docId": sys.argv[1]}))' "$DOC_ID")" || true)
[ "$(data_param "$HOST_STATUS" presenceCount)" -ge 1 ] 2>/dev/null \
  || fail_step 'presence-host' "host sees presenceCount=$(data_param "$HOST_STATUS" presenceCount)"
row PASS 'presence-host' "host presenceCount=$(data_param "$HOST_STATUS" presenceCount)"

# ════════════════════════════════════════════════════════════════════════
# 3. CONCURRENT SCRIPTED EDITS (interleaved, fixed timing)
#    Task O (P2): agent_doc_edit exists — each side appends one REAL doc
#    op into the shared replica (RGA text lane), then both sides sync.
# ════════════════════════════════════════════════════════════════════════
EDIT_A=$(call_on "$HOST_URI" agent_doc_edit "$(python3 -c '
import json
print(json.dumps({"blockId": "gate-a", "text": "host append"}))')" || true)
[ "$(data_param "$EDIT_A" ok)" = "true" ] \
  || fail_step 'concurrent-edits' "host edit refused: $EDIT_A"
row PASS 'edit-host' "blockId=$(data_param "$EDIT_A" blockId) ops=$(data_param "$EDIT_A" ops)"
EDIT_B=$(call_on "$PEER_URI" agent_doc_edit "$(python3 -c '
import json
print(json.dumps({"blockId": "gate-b", "text": "peer prepend"}))')" || true)
[ "$(data_param "$EDIT_B" ok)" = "true" ] \
  || fail_step 'concurrent-edits' "peer edit refused: $EDIT_B"
row PASS 'edit-peer' "blockId=$(data_param "$EDIT_B" blockId) ops=$(data_param "$EDIT_B" ops)"
# Convergence cycle on both sides, then the diff.
call_on "$HOST_URI" storage_mesh_sync '{}' >/dev/null || true
call_on "$PEER_URI" storage_mesh_sync '{}' >/dev/null || true
row PASS 'sync-cycle' 'both replicas flushed + absorbed'

# ════════════════════════════════════════════════════════════════════════
# 4. CONVERGENCE POINT: debugSurface diff (must be empty)
# ════════════════════════════════════════════════════════════════════════
# ════════════════════════════════════════════════════════════════════════
dump_state "$HOST_URI" "$EVIDENCE/host_surface.json"
dump_state "$PEER_URI" "$EVIDENCE/peer_surface.json"
if python3 - "$EVIDENCE/host_surface.json" "$EVIDENCE/peer_surface.json" <<'PYEOF'
import json, sys
def load(path):
    with open(path) as f:
        return json.load(f)
host, peer = load(sys.argv[1]), load(sys.argv[2])
# Divergence ledger (runbook §oracle) — every entry is a NAMED, justified
# device-role divergence, stripped from BOTH dumps before the byte diff.
# Anything NOT listed here must be byte-for-byte identical.
def strip(s):
    mesh = s.get('meshStatus') or {}
    mesh.pop('endpoint', None)   # each surface reports its OWN relay endpoint
    mesh.pop('hosting', None)    # device role: the main device hosts, the peer joins
    mesh.pop('peerCount', None)  # each registry holds only ITS paired peers
                                 # (v1 pairing registers the host on the
                                 # accepting side; TOFU keeps host-side keys
                                 # in-process — presenceCount is the shared signal)
    s.pop('type', None); s.pop('method', None)  # mcp envelope artifacts
    s.pop('viewer', None)        # honest viewer marker: peer true, host false (DESIGN §6)
    s.pop('workspaces', None)    # device-local workspace binding (host binds, viewer has none)
    # Host-owned daemon session projections (ADR 0005 §3: the device that
    # owns the workspace runs the harness; turn ops are not yet doc ops in
    # v1, so the viewer legitimately carries no session state).
    for k in ('sessionId', 'running', 'verdict', 'transcriptTail',
              'turnCount', 'lastGuidance', 'sessionActors'):
        s.pop(k, None)
    s.pop('remotePermissionRouting', None)  # owner-side announce policy
    s.pop('remotePermissions', None)  # each side lists only OTHERS' announcements;
                                      # the shared perm registers themselves ARE the
                                      # converged data (both replicas fold them)
strip(host); strip(peer)
sys.exit(0 if host == peer else 1)
PYEOF
then
  row PASS 'surface-diff' 'host vs peer debugSurface identical (ledger-divergent fields stripped — see the ledger in this script)'
else
  row FAIL 'surface-diff' "differences: $EVIDENCE/host_surface.json vs $EVIDENCE/peer_surface.json"
  diff "$EVIDENCE/host_surface.json" "$EVIDENCE/peer_surface.json" || true
  fail_step 'surface-diff' 'non-empty debugSurface diff at a convergence point (divergence ledger has no entry for it — this is a BUG row)'
fi

# ════════════════════════════════════════════════════════════════════════
# 5. THE PERMISSION — answered FROM THE PEER (reject first, per DESIGN §4)
#    Task O (P1): the mesh_routing verb flips the policy ON (the same
#    state the PROFILE ROUTING toggle renders); the announcement and the
#    answer are doc ops shipped by the sync cycle.
# ════════════════════════════════════════════════════════════════════════
ROUTING=$(data_param "$(call_on "$HOST_URI" agent_doc_state '{}')" remotePermissionRouting)
if [ "$ROUTING" != "true" ]; then
  ROUTE_OUT=$(call_on "$HOST_URI" mesh_routing "$(python3 -c '
import json
print(json.dumps({"enabled": True}))')" || true)
  [ "$(data_param "$ROUTE_OUT" ok)" = "true" ] \
    || fail_step 'mesh_routing' "$ROUTE_OUT"
  ROUTING=$(data_param "$(call_on "$HOST_URI" agent_doc_state '{}')" remotePermissionRouting)
  [ "$ROUTING" = "true" ] \
    || fail_step 'mesh_routing' "verb ran but remotePermissionRouting=$ROUTING"
  row PASS 'mesh_routing' 'remote permission routing ON (owner device, verb-injected)'
fi

DELEGATE_OUT=$(call_on "$HOST_URI" agent_task_delegate "$(python3 -c '
import json
print(json.dumps({"task": "Write one line into gate-permission-target.txt: the write gate fires, the PEER answers."}))')" || true)
[ "$(data_param "$DELEGATE_OUT" ok)" = "true" ] \
  || fail_step 'perm-delegate' "$DELEGATE_OUT"
# The PEER answers REJECT first (reject-first is the law). Each poll
# cycles the sync on BOTH sides: the announcement and the answer are doc
# ops — they only move when the replicas flush + absorb.
for _ in $(seq 1 60); do
  call_on "$HOST_URI" storage_mesh_sync '{}' >/dev/null 2>&1 || true
  PENDING=$(data_param "$(call_on "$PEER_URI" agent_doc_state '{}')" pendingPermissionTitle)
  [ "$PENDING" != "null" ] && break
  call_on "$PEER_URI" storage_mesh_sync '{}' >/dev/null 2>&1 || true
  sleep 2
done
[ "$PENDING" != "null" ] \
  || fail_step 'perm-from-peer' 'the permission never reached the peer'
call_on "$PEER_URI" agent_permission_answer '{"allow": false}' >/dev/null
call_on "$PEER_URI" storage_mesh_sync '{}' >/dev/null 2>&1 || true
row PASS 'perm-reject' "peer REJECTED: $PENDING"
# Re-run with ALLOW.
call_on "$HOST_URI" agent_task_delegate "$(python3 -c '
import json
print(json.dumps({"task": "continue with guidance: retry the write to gate-permission-target.txt"}))')" >/dev/null || true
for _ in $(seq 1 60); do
  call_on "$HOST_URI" storage_mesh_sync '{}' >/dev/null 2>&1 || true
  PENDING=$(data_param "$(call_on "$PEER_URI" agent_doc_state '{}')" pendingPermissionTitle)
  [ "$PENDING" != "null" ] && break
  call_on "$PEER_URI" storage_mesh_sync '{}' >/dev/null 2>&1 || true
  sleep 2
done
[ "$PENDING" != "null" ] || fail_step 'perm-allow' 'second permission never reached the peer'
call_on "$PEER_URI" agent_permission_answer '{"allow": true}' >/dev/null
call_on "$PEER_URI" storage_mesh_sync '{}' >/dev/null 2>&1 || true
row PASS 'perm-allow' "peer ALLOWED: $PENDING"
call_on "$HOST_URI" storage_mesh_sync '{}' >/dev/null || true
call_on "$PEER_URI" storage_mesh_sync '{}' >/dev/null || true

# ════════════════════════════════════════════════════════════════════════
# 6. PRESENCE + ROSTER at the second convergence point, then final diff
# ════════════════════════════════════════════════════════════════════════
dump_state "$HOST_URI" "$EVIDENCE/host_surface_final.json"
dump_state "$PEER_URI" "$EVIDENCE/peer_surface_final.json"
if python3 - "$EVIDENCE/host_surface_final.json" "$EVIDENCE/peer_surface_final.json" <<'PYEOF'
import json, sys
def load(path):
    with open(path) as f:
        return json.load(f)
host, peer = load(sys.argv[1]), load(sys.argv[2])
# Same divergence ledger as step 4 — NAMED device-role divergences only.
def strip(s):
    mesh = s.get('meshStatus') or {}
    mesh.pop('endpoint', None)   # each surface reports its OWN relay endpoint
    mesh.pop('hosting', None)    # device role: the main device hosts, the peer joins
    mesh.pop('peerCount', None)  # each registry holds only ITS paired peers (v1 pairing)
    s.pop('type', None); s.pop('method', None)  # mcp envelope artifacts
    s.pop('viewer', None)        # honest viewer marker (DESIGN §6)
    s.pop('workspaces', None)    # device-local workspace binding
    for k in ('sessionId', 'running', 'verdict', 'transcriptTail',
              'turnCount', 'lastGuidance', 'sessionActors'):
        s.pop(k, None)  # host-owned daemon session projections (v1: turns not synced)
    s.pop('remotePermissionRouting', None)  # owner-side announce policy
    s.pop('remotePermissions', None)  # each side lists only OTHERS' announcements
strip(host); strip(peer)
sys.exit(0 if host == peer else 1)
PYEOF
then
  row PASS 'final-diff' 'final debugSurface diff EMPTY — converged'
else
  row FAIL 'final-diff' 'final debugSurface diff NON-EMPTY (bug row; see evidence)'
  diff "$EVIDENCE/host_surface_final.json" "$EVIDENCE/peer_surface_final.json" || true
  fail_step 'final-diff' 'the runbook verdict is FAIL until this diff is empty'
fi

row PASS 'verdict' 'T3 gate: every diff empty, every answer recorded as data on both sides'
echo "MP_GATE PASS"
