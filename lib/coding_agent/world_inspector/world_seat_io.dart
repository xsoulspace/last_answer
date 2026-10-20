// ignore_for_file: lines_longer_than_80_chars, implementation_imports, avoid_classes_with_only_static_members

/// IO — the seat channel driven by the host package's
/// [HarnessSeatWsClient] (ADR 0072 §5): request the seat from the
/// paired world's advertised channel, then run allowlisted tools over
/// it. Every call opens a fresh session; the daemon's authority
/// re-authorizes each. Failures name themselves (honest surfaces).
library;

import 'package:lastanswer/coding_agent/world_inspector/world_seat_lease.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:xsoulspace_agentic_host/src/harness_mcp_client.dart';
import 'package:xsoulspace_agentic_host/src/harness_seat_ws.dart';
import 'package:xsoulspace_agentic_host/src/participant_identity.dart';

/// The seat channel for a paired world (ADR 0072 §5).
abstract final class WorldSeatChannel {
  static Future<ParticipantIdentity>? _humanParticipant;

  /// An opaque local installation subject, independent of document, world,
  /// connection and model. This declares continuity, never authentication or
  /// authority; the existing owner admission policy still decides the grant.
  static Future<ParticipantIdentity> humanParticipant() =>
      _humanParticipant ??= () async {
        final prefs = await SharedPreferences.getInstance();
        const key = 'world_seat.human_subject.v1';
        var subject = prefs.getString(key);
        if (subject == null || subject.isEmpty) {
          subject = const Uuid().v4();
          if (!await prefs.setString(key, subject)) {
            throw StateError('human_participant_persistence_failed');
          }
        }
        return ParticipantIdentity.requested(
          issuer: 'lastanswer-local-installation',
          subject: subject,
          kind: 'human',
        );
      }();

  /// Earns a seat for [actor] from [seatWs] (`ws://host:port/…`) using
  /// the pairing's bearer [token]. Null when the world advertises no
  /// usable channel (read-only world).
  static Future<WorldSeatLease?> request({
    required final String seatWs,
    required final String token,
    final String actor = 'device-1',
    final String localSocket = '',
    final String docId = '',
  }) async {
    if (localSocket.isNotEmpty) {
      final participant = actor == 'lastanswer-human'
          ? await humanParticipant()
          : null;
      final seatedActor = participant?.actorForFamily('lastanswer') ?? actor;
      final client = await HarnessMcpClient.joinLocal(
        path: localSocket,
        actor: seatedActor,
        task: 'Human connection through Last Answer',
        docId: docId,
        participant: participant?.toJson(),
      );
      try {
        final orientation = await client.call('agent_context', {
          'op': 'orient',
          'query': 'Connect to a world conversation',
        });
        if (orientation['ok'] != true) {
          throw StateError(
            '${orientation['bounce'] ?? 'seat_orientation_failed'}',
          );
        }
        return WorldSeatLease(
          credential: '',
          actor: seatedActor,
          tools: {for (final tool in client.contracts!.tools) tool.name},
          invoke: client.call,
          disconnect: client.close,
        );
      } on Object {
        await client.close();
        rethrow;
      }
    }
    final uri = Uri.tryParse(seatWs);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty || token.isEmpty) {
      return null;
    }
    final client = HarnessSeatWsClient(
      host: uri.host,
      port: uri.port,
      token: token,
    );
    final seat = await client
        .requestSeat(actor: actor)
        .timeout(const Duration(seconds: 15));
    return WorldSeatLease(credential: seat.credential, tools: seat.tools);
  }

  /// One allowlisted tool call over the seat.
  static Future<Map<String, Object?>> call(
    final WorldSeatLease lease, {
    required final String seatWs,
    required final String token,
    required final String name,
    final Map<String, Object?> args = const {},
  }) {
    if (lease.invoke case final invoke?) return invoke(name, args);
    final uri = Uri.tryParse(seatWs);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('bad seat endpoint: $seatWs');
    }
    final client =
        HarnessSeatWsClient(host: uri.host, port: uri.port, token: token)
          ..credential = lease.credential
          ..tools = lease.tools;
    return client.callTool(name, args).timeout(const Duration(seconds: 30));
  }
}
