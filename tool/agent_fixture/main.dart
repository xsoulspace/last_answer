/// Agent-doc self-profiling fixture (ADR 0003 Phase 1).
///
/// DELIBERATELY failing: `dart run tool/agent_fixture/main.dart` exits
/// non-zero until an agent fixes it. The self-profile integration test
/// delegates exactly that task through the embedded harness (AFM,
/// on-device), grades it with this command as the doc's check override,
/// and RESTORES this file afterwards (`git checkout -- tool/agent_fixture`)
/// so the gate stays honest on every run (never trivially green — R5).
void main() {
  // The agent's task: make this program exit 0 (print 'ok').
  // ignore: avoid_print
  throw StateError('not implemented — the agent fixes this');
}
