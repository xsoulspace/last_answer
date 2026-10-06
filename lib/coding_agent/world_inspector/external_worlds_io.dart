// ignore_for_file: lines_longer_than_80_chars, implementation_imports

/// VM — the external-worlds attach (the "connect to the harness pointed
/// from ZCode/Codex" route): scan `~/.xsoulspace/worlds/*.json` for LIVE
/// daemons (pid-checked) and attach through the http serve facade ONLY.
/// `allowSpawn: false` as a law: an embed never spawns a daemon — a
/// world without its facade armed refuses honestly ("arm
/// `harnessd --serve`"), it is never approximated by a new spawn.
///
/// Discovery never grants authority (ADR 0040): observation rides the
/// facade's read-only state; operation stays with the client's own
/// harnessd MCP seat.
library;

import 'dart:convert';
import 'dart:io';

import 'package:lastanswer/coding_agent/world_inspector/paired_worlds.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/http_source.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/source.dart';
import 'package:xsoulspace_agentic_host/src/world_manifest.dart'
    show WorldManifest;
import 'package:xsoulspace_agentic_host/src/world_manifest_io.dart'
    show WorldManifestIO;


/// Resolves the attachable world for [worldId] (null = first):
/// manifests first (same-device, the ZCode/Codex route), then the
/// PAIRED-WORLD registry (ADR 0072 — off-device, discovery rode the
/// signed pairing envelope). Both routes attach through the http
/// facade ONLY; the paired route carries its bearer token when the
/// advertiser served beyond loopback.
Future<TraceSource?> resolveExternalAsync({final String? worldId}) async {
  final local = resolveExternal(worldId: worldId);
  if (local != null) return local;
  final paired = await PairedWorlds.load();
  for (final w in paired) {
    if (worldId != null && w.worldId != worldId) continue;
    if (w.token.isEmpty) continue; // loopback-only advertiser —
    // unreachable from this device; keep looking rather than attach
    // to a guaranteed-refusing facade.
    return HttpTraceSource(
      base: Uri.parse(w.endpoint),
      worldId: w.worldId,
      headers: {'Authorization': 'Bearer ${w.token}'},
    );
  }
  return null;
}

TraceSource? resolveExternal({final String? worldId}) {
  for (final m in WorldManifestIO.scan()) {
    if (worldId != null && m.worldId != worldId) continue;
    for (final t in m.transports) {
      if (t.kind != 'http') continue;
      final base = t.options['base'];
      if (base is! String) continue;
      return HttpTraceSource(base: Uri.parse(base), worldId: m.worldId);
    }
  }
  return null;
}

List<WorldManifest> liveWorlds() => WorldManifestIO.scan();

/// The HOST side of ADR 0072: the harness-world announcement embedded
/// in this device's pairing code when a live world serves beyond
/// loopback. Reads the pid-checked manifests; for each world whose
/// serve block names a bearer token, reads the mode-600 token file
/// (same user by law). Worlds without a reachable endpoint are
/// honestly absent.
Future<List<Map<String, Object?>>> buildWorldAnnouncement() async {
  final announcement = <Map<String, Object?>>[];
  for (final m in WorldManifestIO.scan()) {
    final serve = m.serve;
    if (serve == null) continue;
    final endpoint = serve['endpoint'];
    if (endpoint is! String || endpoint.isEmpty) continue;
    String token = '';
    final tokenFile = serve['tokenFile'];
    if (tokenFile is String && tokenFile.isNotEmpty) {
      try {
        token = File(tokenFile).readAsStringSync().trim();
      } on Object catch (_) {
        continue; // unreadable token = unreachable facade; honest skip
      }
    }
    if (token.isEmpty) continue;
    announcement.add({
      'worldId': m.worldId,
      'endpoint': endpoint,
      'token': token,
      if (m.workspace != null) 'workspace': m.workspace,
      // ADR 0072 §5 — the seat channel's endpoint rides along so the
      // phone can EARN its seat without a second discovery hop.
      if (serve['seatWs'] is String) 'seatWs': serve['seatWs'],
    });
  }
  return announcement;
}

/// Wire convenience: the announcement envelope for a pairing code
/// (empty when no world serves beyond loopback — the field is omitted).
Future<Map<String, Object?>?> buildPairingApplicationData() async {
  final worlds = await buildWorldAnnouncement();
  if (worlds.isEmpty) return null;
  return {'worlds': worlds};
}

/// Debug/verb surface: the paired registry as JSON (equal readers).
Future<List<Map<String, Object?>>> pairedWorldsJson() async {
  final worlds = await PairedWorlds.load();
  return [for (final w in worlds) w.toJson()];
}

/// Exposed for the world_inspector tools (attach reads via the async
/// route now).
Future<String> pairedWorldsDebugLine() async {
  final worlds = await PairedWorlds.load();
  if (worlds.isEmpty) return 'no paired worlds';
  return [
    for (final w in worlds)
      '${w.worldId} @ ${w.endpoint}'
          '${w.workspace == null ? '' : ' (${w.workspace})'} '.trim(),
  ].join(', ');
}

/// jsonEncode re-export for the tools file (keeps its imports clean).
String encodeJson(final Object? value) => jsonEncode(value);
