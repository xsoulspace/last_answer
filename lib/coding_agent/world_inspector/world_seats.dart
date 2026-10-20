// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

/// The conditional barrel for the seat channel: io drives the real
/// client; web answers honest absence (read-only rung only).
library;

import 'package:lastanswer/coding_agent/world_inspector/world_seat_lease.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_seat_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/world_inspector/world_seat_io.dart'
    as impl;

export 'package:lastanswer/coding_agent/world_inspector/world_seat_lease.dart';

/// The seat channel for a paired world (ADR 0072 §5).
abstract final class WorldSeatChannel {
  /// Earns a seat from the paired world's advertised channel. Null =
  /// no usable channel (read-only world, or web).
  static Future<WorldSeatLease?> request({
    required final String seatWs,
    required final String token,
    final String actor = 'device-1',
    final String localSocket = '',
    final String docId = '',
  }) => impl.WorldSeatChannel.request(
    seatWs: seatWs,
    token: token,
    actor: actor,
    localSocket: localSocket,
    docId: docId,
  );

  /// One allowlisted tool call over the seat.
  static Future<Map<String, Object?>> call(
    final WorldSeatLease lease, {
    required final String seatWs,
    required final String token,
    required final String name,
    final Map<String, Object?> args = const {},
  }) => impl.WorldSeatChannel.call(
    lease,
    seatWs: seatWs,
    token: token,
    name: name,
    args: args,
  );
}
