import 'dart:io';

import 'package:lastanswer/settings/features/supervisor_view.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:path_provider/path_provider.dart';

/// On-device supervisor read surface for Last Answer (oka ADR-0041 §6,
/// the SEE half of the LA integration): plans authored in-app live in a
/// [SpecStore], this device's records live in the machine registry, and
/// [load] projects both into one status view.
///
/// Read-only by construction: nothing here converges, spawns, or
/// signals — declaring an automation records it; running it is the
/// converge/resident rung's business (oka ADR-0042, proposed).
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
    for (final name in view.plans) {
      try {
        final desired = store.load(name);
        if (desired != null) specs.addAll(desired.specs);
      } on SpecFormatException {
        view.corruptRecords.add('plan "$name" is not a valid document');
      }
    }

    // Records live under the machine registry (~/.oka); without a HOME
    // there is nothing to read — declared plans still render.
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      for (final spec in specs) {
        view.automations.add(
          SupervisorAutomationView.declared(
            spec.id,
            spec.policy.shape.name,
            spec.trigger.describe(),
          ),
        );
      }
      return view;
    }
    final registry = registryRoot == null
        ? MachineRegistry.forMachine()
        : MachineRegistry(root: registryRoot);
    final snapshot = registry.snapshot(registry.scopeFor(appRoot.path));
    view.corruptRecords.addAll(snapshot.corruptPaths);

    final statuses = projectStatus(
      snapshot: snapshot,
      desired: DesiredState(specs: specs),
    );
    for (final status in statuses) {
      view.automations.add(
        SupervisorAutomationView(
          id: status.componentId,
          shape: status.shape ?? 'service',
          trigger: status.trigger ?? 'none',
          present: status.present,
          drifted: status.drifted,
          epoch: status.epoch,
          restartCount: status.restartCount,
          lastRun: status.lastRun,
        ),
      );
    }
    return view;
  }
}
