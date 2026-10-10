/// Pure view types for the supervisor read surface — shared by the io
/// implementation and the non-io stub, no dart:io anywhere.
library;

/// One automation row for the pane.
final class SupervisorAutomationView {
  SupervisorAutomationView({
    required this.id,
    required this.shape,
    required this.trigger,
    required this.present,
    required this.drifted,
    this.epoch,
    this.restartCount,
    this.lastRun,
  });

  /// A spec declared in a device plan with no record on this device.
  factory SupervisorAutomationView.declared(
    final String id,
    final String shape,
    final String trigger,
  ) => SupervisorAutomationView(
    id: id,
    shape: shape,
    trigger: trigger,
    present: false,
    drifted: false,
  );

  final String id;
  final String shape;
  final String trigger;

  /// A record exists on this device (the supervisor started it here).
  final bool present;

  /// The record's revision hash differs from the declared plan.
  final bool drifted;

  final int? epoch;
  final int? restartCount;
  final String? lastRun;
}

/// Everything the pane renders, one load.
final class SupervisorView {
  SupervisorView({required this.supported});

  final bool supported;
  final List<String> plans = <String>[];
  final List<SupervisorAutomationView> automations =
      <SupervisorAutomationView>[];
  final List<String> corruptRecords = <String>[];
}
