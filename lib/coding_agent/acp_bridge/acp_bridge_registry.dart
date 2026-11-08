/// Item 2e — the ACP bridge's static live registry: which bridges are
/// running on THIS device, which permission interrupts they have open,
/// and which ACP agents detection last found.
///
/// Laws:
/// - Device-local facts, honestly scoped: a bridged ACP agent is bound
///   to the process that spawned it. The registry is the app-run's
///   truth about those bindings; an app restart starts empty (v1:
///   bridges are re-created by the human, the durable ACTOR identity
///   survives in the world record — re-binding the transport across
///   restarts is named runway, not a silent gap).
/// - The permissions list is the [WorldStateService.permissions] merge
///   source: bridge rows arrive in the SAME [InboxPermission] shape the
///   0c reject-first cards already render, with `actorId` attribution,
///   so the room join and the cards work unchanged.
/// - Rows are removed on answer (an answered interrupt is not a fact
///   anymore) and on bridge stop (a dead bridge has no open requests).
library;

// The registry is a device-scoped static by design (the merge point the
// WorldStateService reads and bridges write); the house pattern for a
// pure static holder is this file-level ignore (see world_seats.dart).
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/foundation.dart';

import 'package:lastanswer/coding_agent/acp_bridge/acp_actor_bridge.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';

/// The desktop gate's pure answer (pinned by tests): the bridge needs a
/// native desktop platform (an ACP agent is a spawned local process) AND
/// at least one detected agent (never fake one).
enum AcpBridgeAvailability { available, unsupportedPlatform, noAgentsDetected }

/// The pure availability law: [platform] is [Platform.operatingSystem]
/// vocabulary; [agentIds] is the detection's honest result (empty =
/// nothing on PATH).
AcpBridgeAvailability acpBridgeAvailability(
  final List<String> agentIds,
  final String platform,
) => switch (platform) {
  'macos' || 'linux' || 'windows' => agentIds.isEmpty
      ? AcpBridgeAvailability.noAgentsDetected
      : AcpBridgeAvailability.available,
  _ => AcpBridgeAvailability.unsupportedPlatform,
};

/// The static bridge-side registry (the WorldStateService merge point).
final class AcpBridgeRegistry {
  AcpBridgeRegistry._();

  /// Open permission interrupts raised through bridges, in the 0c
  /// [InboxPermission] shape ([WorldStateService.permissions] appends
  /// this list verbatim).
  static final ValueNotifier<List<InboxPermission>> permissions =
      ValueNotifier<List<InboxPermission>>(const <InboxPermission>[]);

  /// The live bridges on this device (observability rows read this;
  /// a stopped bridge removes itself).
  static final ValueNotifier<List<AcpActorBridge>> bridges =
      ValueNotifier<List<AcpActorBridge>>(const <AcpActorBridge>[]);

  /// The last agent detection's result: null = never detected on this
  /// app run (honest unknown — the picker row treats it separately from
  /// an empty list, which means "detected, found none").
  static final ValueNotifier<List<AcpAgentInstallation>?> detectedAgents =
      ValueNotifier<List<AcpAgentInstallation>?>(null);

  /// Adds one permission row (the bridge calls this when the agent asks).
  static void addPermission(final InboxPermission permission) {
    permissions.value = <InboxPermission>[
      ...permissions.value,
      permission,
    ];
  }

  /// Removes the row with [sessionId] (on answer or bridge stop).
  static void removePermission(final String sessionId) {
    if (!permissions.value.any((final row) => row.sessionId == sessionId)) {
      return;
    }
    permissions.value = <InboxPermission>[
      for (final row in permissions.value)
        if (row.sessionId != sessionId) row,
    ];
  }

  /// Registers one started bridge.
  static void register(final AcpActorBridge bridge) {
    if (bridges.value.contains(bridge)) return;
    bridges.value = <AcpActorBridge>[...bridges.value, bridge];
  }

  /// Removes one bridge (its [AcpActorBridge.stop] calls this).
  static void unregister(final AcpActorBridge bridge) {
    if (!bridges.value.contains(bridge)) return;
    bridges.value = <AcpActorBridge>[
      for (final row in bridges.value)
        if (row != bridge) row,
    ];
  }

  /// Detects the installed ACP agents (discovery WITHOUT execution —
  /// [AcpInstallationService.detectAll] probes PATH only) and caches the
  /// result for the picker row. A failed detection keeps the previous
  /// cache (or the honest empty list) — never a crash, never a fake.
  static Future<List<AcpAgentInstallation>> detectAgents({
    final AcpInstallationService? installationService,
  }) async {
    final service = installationService ?? AcpInstallationService();
    try {
      final found = await service.detectAll();
      detectedAgents.value = List<AcpAgentInstallation>.unmodifiable(found);
    } on Object {
      detectedAgents.value ??= const <AcpAgentInstallation>[];
    }
    return detectedAgents.value ?? const <AcpAgentInstallation>[];
  }

  /// The detected agents' ids (the pure availability helper's input).
  static List<String> detectedAgentIds() => [
    for (final installation in detectedAgents.value ??
        const <AcpAgentInstallation>[])
      installation.entry.id,
  ];

  /// Test hygiene: drops every bridge row, permission row and the
  /// detection cache (production never calls this — bridges stop
  /// individually and remove their own rows).
  @visibleForTesting
  static void debugReset() {
    permissions.value = const <InboxPermission>[];
    bridges.value = const <AcpActorBridge>[];
    detectedAgents.value = null;
  }
}
