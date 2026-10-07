import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:lastanswer/doc/acp_agent_runtime.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:universal_io/io.dart';

/// What THIS device can host for the fleet — the multiplayer
/// "advertise, then route by capability facts" recommendation as typed
/// data. The snapshot is HONEST BY CONSTRUCTION: every field answers a
/// probe or a detection that actually ran (never a hardcoded claim), so
/// a peer routing a laya decision or an ACP turn here reads facts, not
/// advertising.
///
/// Wi-Fi scope: the mesh fields describe the LAN pairing (hosting /
/// connected peers) — there is no internet transport in this app's
/// multiplayer path by decision, and none is advertised here.
final class DeviceCapabilitySnapshot {
  const DeviceCapabilitySnapshot({
    required this.platform,
    required this.peerId,
    required this.meshHosting,
    required this.meshConnected,
    required this.acpAgentIds,
    required this.afmAvailable,
    required this.layaEndpoint,
    required this.layaReachable,
    required this.hostedChatCredential,
    required this.sampledAt,
  });

  /// Gathers the live snapshot. [hostedChatCredential] answers whether a
  /// hosted-model credential is resolvable on this device (the caller
  /// owns the store lookup — device_capabilities stays storage-free).
  static Future<DeviceCapabilitySnapshot> gather({
    required final AcpInstallationService installationService,
    required final bool hostedChatCredential,
    final Uri? layaEndpoint,
    final http.Client? httpClient,
  }) async {
    final notifier = StorageBackendsNotifier.instance;
    var installations = const <String>[];
    if (PlatformInfo.isNativeDesktop) {
      try {
        installations = [
          for (final installation in await installationService.detectAll())
            installation.entry.id,
        ];
      } on Object {
        installations = const [];
      }
    }
    final endpoint =
        layaEndpoint ??
        Uri.parse(
          Platform.environment['LAYA_DECISION_ENDPOINT'] ??
              'http://127.0.0.1:8000/v1/systemone',
        );
    final layaReachable = await _probeLaya(endpoint, httpClient);
    return DeviceCapabilitySnapshot(
      platform: Platform.operatingSystem,
      peerId: notifier.meshService?.selfId,
      meshHosting: notifier.meshService?.isHosting ?? false,
      meshConnected: notifier.meshService?.isConnected ?? false,
      acpAgentIds: installations,
      afmAvailable: PlatformInfo.isMacOS,
      layaEndpoint: endpoint.toString(),
      layaReachable: layaReachable,
      hostedChatCredential: hostedChatCredential,
      sampledAt: DateTime.now().toUtc(),
    );
  }

  /// One bounded GET to the laya health endpoint (attach-only, never a
  /// spawn): any answering status below 500 counts as alive — the same
  /// contract LayaServeRuntime's probe uses.
  static Future<bool> _probeLaya(
    final Uri endpoint,
    final http.Client? httpClient,
  ) async {
    final client = httpClient ?? http.Client();
    try {
      final health = endpoint.replace(path: '/health');
      final response = await client
          .get(health)
          .timeout(const Duration(seconds: 2));
      return response.statusCode >= 200 && response.statusCode < 500;
    } on Object {
      return false;
    } finally {
      if (httpClient == null) client.close();
    }
  }

  final String platform;
  final String? peerId;
  final bool meshHosting;
  final bool meshConnected;
  final List<String> acpAgentIds;

  /// The Apple-foundation decision lane (on-device AFM) — macOS only.
  final bool afmAvailable;
  final String layaEndpoint;
  final bool layaReachable;
  final bool hostedChatCredential;
  final DateTime sampledAt;

  Map<String, Object?> toJson() => {
    'platform': platform,
    'peerId': peerId,
    'mesh': {'hosting': meshHosting, 'connected': meshConnected},
    'capabilities': {
      'acp_agents': acpAgentIds,
      'afm': afmAvailable,
      'laya': {'endpoint': layaEndpoint, 'reachable': layaReachable},
      'hosted_chat': hostedChatCredential,
    },
    'sampledAt': sampledAt.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());
}
