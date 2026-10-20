// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

/// WEB STUB — the seat channel needs sockets (dart:io). The web build
/// answers honest absence: the read rung (the http facade) is the whole
/// surface there.
library;

import 'package:lastanswer/coding_agent/world_inspector/world_seat_lease.dart';

/// The seat channel for a paired world (ADR 0072 §5).
abstract final class WorldSeatChannel {
  /// Earns a seat from the paired world's advertised channel. Null =
  /// no seat channel on web (honest absence, never a fake grant).
  static Future<WorldSeatLease?> request({
    required final String seatWs,
    required final String token,
    final String actor = 'device-1',
    final String localSocket = '',
    final String docId = '',
  }) async => null;

  /// One allowlisted tool call over the seat. Never reachable on web —
  /// the request rung refuses first.
  static Future<Map<String, Object?>> call(
    final WorldSeatLease lease, {
    required final String seatWs,
    required final String token,
    required final String name,
    final Map<String, Object?> args = const {},
  }) async =>
      throw UnsupportedError('the seat channel needs a native platform');
}
