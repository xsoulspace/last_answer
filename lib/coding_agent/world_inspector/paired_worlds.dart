/// The paired-worlds registry (ADR 0072): harness worlds a PEER
/// advertised inside its signed pairing envelope — the off-device
/// discovery route (the `~/.xsoulspace/worlds` manifest scan cannot
/// exist on another device). Trust model: an entry got here only
/// through a VERIFIED pairing (the envelope signature bound it to the
/// advertiser's identity), so storing it keeps that trust; it never
/// grants authority — the facade token it carries is read-only and
/// LAN-scoped.
///
/// Persistence is one SharedPreferences JSON blob (the same store the
/// storage backends use) — small, synchronous to read, per device.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One advertised harness world, as the pairing carried it.
final class PairedWorld {
  const PairedWorld({
    required this.worldId,
    required this.endpoint,
    required this.token,
    required this.pairedAt,
    this.workspace,
  });

  factory PairedWorld.fromJson(final Map<String, Object?> json) =>
      PairedWorld(
        worldId: json['worldId'] as String? ?? '',
        endpoint: json['endpoint'] as String? ?? '',
        token: json['token'] as String? ?? '',
        workspace: json['workspace'] as String?,
        pairedAt:
            DateTime.tryParse(json['pairedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Builds from the pairing envelope's `worlds` entry (missing fields
  /// make the entry unusable — the caller drops it honestly).
  static PairedWorld? fromAnnouncement(final Object? json) {
    if (json is! Map) return null;
    final worldId = json['worldId'];
    final endpoint = json['endpoint'];
    final token = json['token'];
    if (worldId is! String ||
        worldId.isEmpty ||
        endpoint is! String ||
        endpoint.isEmpty) {
      return null;
    }
    return PairedWorld(
      worldId: worldId,
      endpoint: endpoint,
      token: token is String ? token : '',
      workspace: json['workspace'] is String
          ? json['workspace'] as String
          : null,
      pairedAt: DateTime.now().toUtc(),
    );
  }

  final String worldId;
  final String endpoint;

  /// The facade's bearer token (empty when the facade is loopback-only
  /// on the advertiser — an entry that cannot be reached off-device).
  final String token;
  final String? workspace;
  final DateTime pairedAt;

  Map<String, Object?> toJson() => {
    'worldId': worldId,
    'endpoint': endpoint,
    'token': token,
    'workspace': ?workspace,
    'pairedAt': pairedAt.toIso8601String(),
  }
    ..removeWhere((final _, final v) => v == null || v == '');
}

/// The registry: one device's stored paired worlds.
final class PairedWorlds {
  PairedWorlds._();
  static const _key = 'world_inspector.paired_worlds.v1';

  /// All stored entries, newest pairing first.
  static Future<List<PairedWorld>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final worlds = [
        for (final e in decoded)
          if (e is Map) PairedWorld.fromJson(Map<String, Object?>.from(e)),
      ].where((final w) => w.worldId.isNotEmpty && w.endpoint.isNotEmpty);
      final unique = <String, PairedWorld>{
        for (final w in worlds) w.worldId: w,
      };
      final list = unique.values.toList()
        ..sort((final a, final b) => b.pairedAt.compareTo(a.pairedAt));
      return list;
    } on FormatException {
      return const [];
    }
  }

  /// Merges an announcement's entries (newest wins per worldId).
  static Future<void> storeAnnouncement(
    final List<Object?>? worlds,
  ) async {
    if (worlds == null || worlds.isEmpty) return;
    final announced = [
      for (final e in worlds)
        ?PairedWorld.fromAnnouncement(e),
    ].whereType<PairedWorld>().toList();
    if (announced.isEmpty) return;
    final existing = await load();
    final merged = <String, PairedWorld>{
      for (final w in existing) w.worldId: w,
      for (final w in announced) w.worldId: w,
    };
    final list = merged.values.toList()
      ..sort((final a, final b) => b.pairedAt.compareTo(a.pairedAt));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final w in list) w.toJson()]),
    );
  }

  /// Test/teardown escape hatch — a fresh registry per test.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
