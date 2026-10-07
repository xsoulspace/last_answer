// ignore_for_file: lines_longer_than_80_chars, implementation_imports, avoid_classes_with_only_static_members

/// IO — the seat channel driven by the host package's
/// [HarnessSeatWsClient] (ADR 0072 §5): request the seat from the
/// paired world's advertised channel, then run allowlisted tools over
/// it. Every call opens a fresh session; the daemon's authority
/// re-authorizes each. Failures name themselves (honest surfaces).
library;

import 'package:lastanswer/coding_agent/world_inspector/world_seat_lease.dart';
import 'package:xsoulspace_agentic_host/src/harness_seat_ws.dart';

/// The seat channel for a paired world (ADR 0072 §5).
abstract final class WorldSeatChannel {
  /// Earns a seat for [actor] from [seatWs] (`ws://host:port/…`) using
  /// the pairing's bearer [token]. Null when the world advertises no
  /// usable channel (read-only world).
  static Future<WorldSeatLease?> request({
    required final String seatWs,
    required final String token,
    final String actor = 'device-1',
  }) async {
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
    final uri = Uri.tryParse(seatWs);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('bad seat endpoint: $seatWs');
    }
    final client = HarnessSeatWsClient(
      host: uri.host,
      port: uri.port,
      token: token,
    )
      ..credential = lease.credential
      ..tools = lease.tools;
    return client.callTool(name, args).timeout(const Duration(seconds: 30));
  }
}
