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
    this.plan,
    this.command,
    this.args,
    this.intervalSeconds,
    this.atMinutes,
    this.isAgent = false,
    this.instructions,
    this.revision,
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

  /// Raw trigger description (`interval:86400s@03:00`, `none`, ...).
  /// Rows render the human summary ([schedulePhrase] builders live in
  /// the panel, where l10n exists); this stays the canonical form.
  final String trigger;

  /// A record exists on this device (the supervisor started it here).
  final bool present;

  /// The record's revision hash differs from the declared plan.
  final bool drifted;

  final int? epoch;
  final int? restartCount;
  final String? lastRun;

  /// Editable-surface fields (oka ADR-0041 §6, the CREATE half): the
  /// plan the spec lives in and the declaration details the editor
  /// round-trips. Null when the platform cannot edit (web stub).
  final String? plan;
  final String? command;
  final String? args;

  /// Schedule period in seconds for repeating jobs; null = on demand.
  final int? intervalSeconds;

  /// Wall-clock anchor in minutes since midnight (from the plan's
  /// interval `at`); null = unanchored.
  final int? atMinutes;

  /// Declared on the `agent` provider (instructions payload) rather
  /// than a desktop process command.
  final bool isAgent;
  final String? instructions;
  final int? revision;
}

/// What the editor submits for one automation. The io service turns
/// this into a validated plan document (SpecCodec) — the UI never
/// writes JSON by hand.
final class SupervisorAutomationDraft {
  const SupervisorAutomationDraft({
    required this.id,
    required this.isService,
    this.command,
    this.args,
    this.intervalSeconds,
    this.atMinutes,
    this.isAgent = false,
    this.instructions,
    this.plan,
    this.revision,
  });

  /// Stable automation name; also the plan name for new automations
  /// (one automation per plan file, the common authoring shape).
  final String id;

  /// true = service (desired: running); false = job (desired:
  /// succeeded once per revision / schedule). Agent tasks are jobs.
  final bool isService;

  /// Process provider command (desktop only), e.g. `/usr/bin/backup`.
  final String? command;
  final String? args;

  /// Schedule period in seconds for repeating jobs; null = on demand.
  final int? intervalSeconds;

  /// Wall-clock anchor, minutes since midnight; null = unanchored.
  final int? atMinutes;

  /// true = agent task (instructions on the `agent` provider) instead
  /// of a desktop command.
  final bool isAgent;
  final String? instructions;

  /// The plan this automation lives in (edit); null = create.
  final String? plan;

  /// The policy revision to supersede; the service bumps it — the reset
  /// is the revision bump (ADR-0040).
  final int? revision;
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
