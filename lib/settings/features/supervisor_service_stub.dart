import 'package:core/core.dart';
import 'package:lastanswer/settings/features/supervisor_agent_client.dart';
import 'package:lastanswer/settings/features/supervisor_execution_stub.dart';
import 'package:lastanswer/settings/features/supervisor_view.dart';

/// Non-IO stand-in for the supervisor surface: hosting records, plan
/// stores and authoring need dart:io, so web reports unsupported
/// instead of crashing.
final class SupervisorService {
  SupervisorService({required this.storeRoot, required this.appRoot});

  final Object storeRoot;
  final Object appRoot;
  SupervisorExecution? get execution => null;
  bool get executionSupported => false;

  /// The web host has no seat and no world: an agent automation refuses
  /// here in words, never silently.
  SupervisorExecution prepareExecution({
    final SupervisorAgentClientResolver? agentClientResolver,
  }) => throw UnsupportedError('execution needs a desktop host');

  /// The world the OPEN project is bound to — the app's own notion of
  /// the authorized world. Null when the open project binds none.
  static String? authorizedWorldId(final ProjectModel? project) =>
      switch (project) {
        ProjectModelDoc(:final agent?) => agent.worldBinding?.worldId,
        _ => null,
      };

  /// No world is reachable from the web host.
  static Future<SupervisorAgentClientResolution> resolveAgentClient({
    required final String worldId,
  }) async => const SupervisorAgentClientResolution.refused(
    'the web host runs no world — agent automations need a desktop host',
  );

  static Future<SupervisorService> forDevice() =>
      Future<SupervisorService>.value(
        SupervisorService(storeRoot: Object(), appRoot: Object()),
      );

  Future<SupervisorView> load() =>
      Future<SupervisorView>.value(SupervisorView(supported: false));

  Future<void> saveAutomation(final SupervisorAutomationDraft draft) =>
      Future<void>.error(UnsupportedError('supervisor authoring needs io'));

  Future<void> deleteAutomation({
    required final String plan,
    required final String id,
  }) => Future<void>.error(UnsupportedError('supervisor authoring needs io'));
}
