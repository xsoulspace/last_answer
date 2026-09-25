#!/usr/bin/env bash
# MCP smoke test for Last Answer storage backends — no UI needed.
#
# Drives the app-registered dynamic tools (storage_state, select_backend,
# set_path, backup, restore) through flutter-mcp-toolkit's
# `fmt_client_tool` command on a running debug build: selects backends,
# configures paths, replicates a known payload and reads it back for both
# filesystem and gitOffline.
#
# Usage:
#   tool/mcp_storage_smoke.sh                     # auto-discover running app
#   tool/mcp_storage_smoke.sh --uri 'ws://127.0.0.1:PORT/AUTH/ws'
set -euo pipefail

URI_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --uri) URI_ARG="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

FMTK="${FMTK:-fmtk}"
SMOKE_DIR="${SMOKE_DIR:-}"
export PAYLOAD='{"projects":[{"id":"smoke-1","title":"MCP smoke"}],"tags":[]}'

call_tool() { # toolName arguments-json
  local args
  args=$(python3 -c "
import json, sys
args = {
    'toolName': sys.argv[1],
    'arguments': json.loads(sys.argv[2]),
}
if sys.argv[3]:
    args['connection'] = {'uri': sys.argv[3]}
print(json.dumps(args))
" "$1" "$2" "${URI_ARG}")
  "$FMTK" exec --name fmt_client_tool --args "$args"
}

fail() { echo "FAIL: $*" >&2; exit 1; }

check_ok() { # output expected-message-substring label
  echo "$1" | grep -q '"ok": *true' || fail "$3: envelope not ok: $1"
  echo "$1" | grep -q '"message":' || fail "$3: no message: $1"
  if [[ -n "${2:-}" ]]; then
    echo "$1" | grep -q "$2" || fail "$3: missing '$2' in $1"
  fi
  echo "PASS: $3"
}

echo "==> Connecting to running app…"
if [[ -n "$URI_ARG" ]]; then
  STATUS=$("$FMTK" exec --name status \
    --args "{\"connection\":{\"uri\":\"$URI_ARG\"}}")
  echo "$STATUS" | grep -q '"connected": *true' \
    || fail "cannot connect to $URI_ARG (is the debug app running?)"
fi

echo "==> storage_state (baseline)"
STATE=$(call_tool storage_state '{}')
echo "$STATE" | python3 -c "
import json,sys
d=json.load(sys.stdin)
print('state:', json.dumps(d['data']['parameters']['state']))
"
if [[ -z "$SMOKE_DIR" ]]; then
  # Sandboxed apps can only write inside their own container — use the
  # app's documents dir reported by storage_state.
  SMOKE_DIR=$(echo "$STATE" | python3 -c "
import json,sys,os
d=json.load(sys.stdin)
base = d['data']['parameters']['state'].get('defaultPath') or '/tmp'
print(os.path.join(base, 'last_answer_mcp_smoke'))
")
fi
echo "Smoke dir: $SMOKE_DIR"

rm -rf "$SMOKE_DIR"

# Which local backends does this platform support?
SUPPORTED=$(echo "$STATE" | python3 -c "
import json,sys
print(' '.join(json.load(sys.stdin)['data']['parameters']['state'].get('supportedBackends', [])))
")
echo "Supported backends: $SUPPORTED"

run_local_backend() { # backendName
  local B=$1
  if ! echo " $SUPPORTED " | grep -q " $B "; then
    R=$(call_tool storage_backup "{\"backend\":\"$B\",\"payload\":$(python3 -c 'import json,os;print(json.dumps(os.environ["PAYLOAD"]))')}")
    echo "$R" | grep -q 'not available' \
      && echo "SKIP: $B not available on this platform (graceful failure ✓)" \
      || fail "$B expected unavailable but got: $R"
    return
  fi
  R=$(call_tool storage_select_backend "{\"backend\":\"$B\"}")
  check_ok "$R" "" "select $B"

  R=$(call_tool storage_set_path "{\"backend\":\"$B\",\"path\":\"$SMOKE_DIR/$B\"}")
  check_ok "$R" "path set" "set $B path"

  R=$(call_tool storage_backup "{\"backend\":\"$B\",\"payload\":$(python3 -c 'import json,os;print(json.dumps(os.environ["PAYLOAD"]))')}")
  check_ok "$R" "Replicated to $B" "backup to $B"

  [[ -f "$SMOKE_DIR/$B/last-answer-data.json" ]] \
    && grep -q "MCP smoke" "$SMOKE_DIR/$B/last-answer-data.json" \
    && echo "PASS: backup file exists on disk" \
    || fail "backup file missing at $SMOKE_DIR/$B/last-answer-data.json"

  R=$(call_tool storage_restore "{\"backend\":\"$B\",\"apply\":\"false\"}")
  check_ok "$R" "Read backup from $B" "restore (read-only) from $B"
  echo "$R" | grep -q "MCP smoke" || fail "restored payload mismatch"
}

if echo " $SUPPORTED " | grep -q ' filesystem '; then
  echo "==> Filesystem backend: select, configure, backup, restore"
fi
run_local_backend filesystem

if echo " $SUPPORTED " | grep -q ' gitOffline '; then
  echo "==> Git offline backend: select, configure, backup, restore"
fi
run_local_backend gitOffline

# .git check only meaningful when git ran.
if echo " $SUPPORTED " | grep -q ' gitOffline '; then
  [[ -d "$SMOKE_DIR/gitOffline/.git" ]] && echo "PASS: git repo versioned on disk" \
    || fail ".git not found in $SMOKE_DIR/gitOffline"
fi

echo "==> Cleanup: back to localDb"
R=$(call_tool storage_select_backend '{"backend":"localDb"}')
check_ok "$R" "" "back to localDb"

echo ""
echo "ALL STORAGE MCP SMOKE CHECKS PASSED ✓"
