import 'dart:io';

import 'package:lastanswer/settings/features/supervisor_view.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:path_provider/path_provider.dart';

/// On-device supervisor read/write surface for Last Answer (oka ADR-0041
/// §6, the SEE + CREATE halves of the LA integration): plans authored
/// in-app live in a [SpecStore], this device's records live in the
/// machine registry, and [load] projects both into one status view.
///
/// Authoring is validating, never executing: [saveAutomation] and
/// [deleteAutomation] write plan documents through [SpecCodec] (typed
/// values in, validated JSON out). Nothing here converges, spawns, or
/// signals — running an automation is the converge/resident rung's
/// business (oka ADR-0042, proposed).
final class SupervisorService {
  SupervisorService({required this.storeRoot, required this.appRoot});

  /// Directory holding the device-local plans
  /// (`<app-support>/supervisor/plans`).
  final Directory storeRoot;

  /// A stable per-device root whose hash scopes the registry records
  /// (the application support directory).
  final Directory appRoot;

  static Future<SupervisorService> forDevice() async {
    final support = await getApplicationSupportDirectory();
    return SupervisorService(
      storeRoot: Directory('${support.path}/supervisor/plans'),
      appRoot: support,
    );
  }

  /// Projects plans + records into the visual view. Never throws for
  /// data problems: unreadable plans and corrupt records are surfaced
  /// in the view, never crash the pane. [registryRoot] overrides the
  /// machine registry location (tests); the default is `~/.oka/supervisor`.
  Future<SupervisorView> load({final String? registryRoot}) async {
    final view = SupervisorView(supported: true);
    final SpecStore store;
    try {
      store = SpecStore(storeRoot);
    } on Exception {
      return view;
    }
    view.plans.addAll(store.names());

    final specs = <ComponentSpec>[];
    final planOf = <String, String>{};
    for (final name in view.plans) {
      try {
        final desired = store.load(name);
        if (desired == null) continue;
        for (final spec in desired.specs) {
          specs.add(spec);
          planOf[spec.id] = name;
        }
      } on SpecFormatException {
        view.corruptRecords.add('plan "$name" is not a valid document');
      }
    }

    for (final spec in specs) {
      view.automations.add(
        SupervisorAutomationView(
          id: spec.id,
          shape: spec.policy.shape.name,
          trigger: spec.trigger.describe(),
          present: false,
          drifted: false,
          plan: planOf[spec.id],
          command: spec.env['command'],
          args: spec.env['args'],
          intervalSeconds: switch (spec.trigger) {
            IntervalTrigger(:final period) => period.inSeconds,
            _ => null,
          },
          atMinutes: switch (spec.trigger) {
            IntervalTrigger(:final at) when at != null => _atMinutes(at),
            _ => null,
          },
          isAgent: spec.providerName == 'agent',
          instructions: spec.env['instructions'],
          revision: spec.policy.revision,
        ),
      );
    }

    // Records live under the machine registry (~/.oka); without a HOME
    // there is nothing to read — declared plans still render.
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) return view;
    final registry = registryRoot == null
        ? MachineRegistry.forMachine()
        : MachineRegistry(root: registryRoot);
    final snapshot = registry.snapshot(registry.scopeFor(appRoot.path));
    view.corruptRecords.addAll(snapshot.corruptPaths);

    final statuses = projectStatus(
      snapshot: snapshot,
      desired: DesiredState(specs: specs),
    );
    final byId = <String, SupervisorAutomationView>{
      for (final automation in view.automations) automation.id: automation,
    };
    for (final status in statuses) {
      final declared = byId[status.componentId];
      byId[status.componentId] = SupervisorAutomationView(
        id: status.componentId,
        shape: declared?.shape ?? (status.shape ?? 'service'),
        trigger: declared?.trigger ?? (status.trigger ?? 'none'),
        present: status.present,
        drifted: status.drifted,
        epoch: status.epoch,
        restartCount: status.restartCount,
        lastRun: status.lastRun,
        plan: declared?.plan,
        command: declared?.command,
        args: declared?.args,
        intervalSeconds: declared?.intervalSeconds,
        atMinutes: declared?.atMinutes,
        isAgent: declared?.isAgent ?? false,
        instructions: declared?.instructions,
        revision: declared?.revision,
      );
    }
    // Declared rows keep declaration order; records-only rows follow.
    view.automations
      ..clear()
      ..addAll(byId.values);
    return view;
  }

  /// Creates or updates one automation as a plan document. Editing
  /// bumps the policy revision — the reset is the revision bump
  /// (ADR-0040), so the next converge restarts the component.
  ///
  /// New automations get their own one-spec plan named [draft.id];
  /// edits replace the spec in place and preserve plan siblings.
  Future<void> saveAutomation(final SupervisorAutomationDraft draft) async {
    final store = SpecStore(storeRoot);
    final spec = _specOf(draft);
    final planName = draft.plan ?? draft.id;
    final existing =
        store.load(planName) ?? const DesiredState(specs: []);
    final hasSpec = existing.specs.any((final old) => old.id == spec.id);
    final specs = [
      for (final old in existing.specs)
        if (old.id == spec.id) spec else old,
      if (!hasSpec) spec,
    ];
    store.save(planName, DesiredState(specs: specs));
  }

  /// Removes one automation: drops its spec from the plan and deletes
  /// the plan file when it becomes empty.
  Future<void> deleteAutomation({
    required final String plan,
    required final String id,
  }) async {
    final store = SpecStore(storeRoot);
    final existing = store.load(plan);
    if (existing == null) return;
    final specs = [
      for (final spec in existing.specs)
        if (spec.id != id) spec,
    ];
    if (specs.isEmpty) {
      store.delete(plan);
    } else {
      store.save(plan, DesiredState(specs: specs));
    }
  }

  ComponentSpec _specOf(final SupervisorAutomationDraft draft) {
    if (draft.id.isEmpty ||
        draft.id.contains('/') ||
        draft.id.contains('..')) {
      throw const FormatException('automation name is not a valid plan name');
    }
    final period = draft.intervalSeconds;
    final trigger = (period == null || draft.isService)
        ? const NoTrigger()
        : IntervalTrigger(
            period: Duration(seconds: period),
            at: draft.atMinutes == null ? null : _atLabel(draft.atMinutes!),
          );
    return ComponentSpec(
      id: draft.id,
      providerName: draft.isAgent ? 'agent' : 'process',
      policy: SupervisionPolicy(
        shape: draft.isService && !draft.isAgent
            ? SupervisionShape.service
            : SupervisionShape.job,
        revision: (draft.revision ?? 0) + 1,
      ),
      trigger: trigger,
      env: draft.isAgent
          ? {
              if (draft.instructions != null &&
                  draft.instructions!.isNotEmpty)
                'instructions': draft.instructions!,
            }
          : {
              if (draft.command != null && draft.command!.isNotEmpty)
                'command': draft.command!,
              if (draft.args != null && draft.args!.isNotEmpty)
                'args': draft.args!,
            },
    );
  }
}

/// "HH:mm" → minutes since midnight.
int _atMinutes(final String anchor) {
  final (hour, minute) = IntervalTrigger.parseAnchor(anchor);
  return hour * 60 + minute;
}

/// Minutes since midnight → "HH:mm".
String _atLabel(final int minutes) {
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}
