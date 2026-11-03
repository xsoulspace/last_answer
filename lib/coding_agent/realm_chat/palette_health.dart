import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

/// ADR 0119 — the ecsai daemon's palette-health status file, read for the
/// People panel's brain badge: one entry per palette cast with its
/// `status` (`ok · unknown · failed · not_downloaded · downloading ·
/// loading`), a stable `code` and a human `detail` fix hint. The daemon
/// writes the boot snapshot and every runtime wire transition; this is a
/// read-only projection — LA never writes it.
///
/// Process telemetry, not world data: the file describes the daemon's
/// wires, so a stale or missing file renders as "unknown", never as an
/// error surface.
@immutable
final class PaletteBrainHealth {
  const PaletteBrainHealth({
    required this.status,
    this.code,
    this.detail,
    this.at,
  });

  factory PaletteBrainHealth.fromJson(final Map<String, Object?> json) =>
      PaletteBrainHealth(
        status: json['status'] as String? ?? 'unknown',
        code: json['code'] as String?,
        detail: json['detail'] as String?,
        at: json['at'] as String?,
      );

  final String status;
  final String? code;
  final String? detail;
  final String? at;

  bool get isHealthy => status == 'ok' || status == 'unknown';
}

/// Reads and caches the daemon's palette-health file. [resolveHome]
/// defaults to the process environment (`HARNESS_HOME`, else `HOME`) so
/// tests can point it at a scratch directory.
class PaletteHealthStore {
  PaletteHealthStore({String Function()? resolveHome})
    : _resolveHome = resolveHome ?? _defaultHome;

  final String Function() _resolveHome;
  Map<String, PaletteBrainHealth> _entries = const {};
  DateTime? _loadedAt;

  static String _defaultHome() =>
      Platform.environment['HARNESS_HOME'] ??
      Platform.environment['HOME'] ??
      '.';

  /// The health for a brainRef: the cast id (possibly carrying
  /// `local:` parameters) resolved against the daemon's palette. Null
  /// when the palette names no such entry — a local or unknown brain
  /// has no daemon verdict to show.
  PaletteBrainHealth? statusFor(final String brainRef) {
    _ensureLoaded();
    final base = brainRefBase(brainRef).trim();
    if (base.isEmpty) return null;
    return _entries[base];
  }

  void _ensureLoaded() {
    final now = DateTime.now();
    final loaded = _loadedAt;
    if (loaded != null && now.difference(loaded) < const Duration(seconds: 5)) {
      return;
    }
    _loadedAt = now;
    try {
      final path =
          '${_resolveHome()}/.xsoulspace/palette_health.json';
      final file = File(path);
      if (!file.existsSync()) {
        _entries = const {};
        return;
      }
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) {
        _entries = const {};
        return;
      }
      final entries = decoded['entries'];
      if (entries is! Map) {
        _entries = const {};
        return;
      }
      _entries = <String, PaletteBrainHealth>{
        for (final entry in entries.entries)
          if (entry.value is Map)
            entry.key as String: PaletteBrainHealth.fromJson(
              (entry.value as Map).cast<String, Object?>(),
            ),
      };
    } on Object {
      // Telemetry is never authoritative: an unreadable file degrades to
      // "no verdict", not an error surface.
      _entries = const {};
    }
  }
}
