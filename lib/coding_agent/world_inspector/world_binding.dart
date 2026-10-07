// ignore_for_file: lines_longer_than_80_chars, implementation_imports

/// The doc → external-world binding: the web-safe half of the connect
/// surface. A binding names a harness world by its http facade endpoint
/// (discovery materialized at pick time — the OSS app connects to
/// whatever the USER chooses, never a hardcoded world; null binding =
/// the embedded in-process world, the default path).
///
/// The read rung rides [HttpTraceSource] (web-safe by design — the
/// facade serves CORS `*`); the WRITE rung (the seat, ADR 0072 §5)
/// needs sockets and lives behind the [world_seats] conditional import.
library;

import 'package:core/core.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/http_source.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/source.dart';

/// One connectable world as discovery materialized it (manifest scan,
/// paired registry, or a user-added endpoint).
final class DiscoveredWorld {
  const DiscoveredWorld({
    required this.worldId,
    required this.endpoint,
    required this.source,
    this.displayName = '',
    this.workspace = '',
    this.token = '',
    this.seatWs = '',
  });

  /// Builds the binding a doc persists for [world]. The token never
  /// enters the binding (device-local trust, never the mesh).
  WorldBindingModel toBinding() => WorldBindingModel(
    worldId: worldId,
    endpoint: endpoint,
    displayName: displayName,
    workspace: workspace,
  );

  final String worldId;
  final String endpoint;

  /// `manifest` (same-device daemon), `paired` (ADR 0072 registry), or
  /// `manual` (user-added endpoint).
  final String source;
  final String displayName;
  final String workspace;

  /// The facade's bearer token (device-local; empty = loopback/no auth).
  final String token;

  /// The advertised seat channel (empty = read-only world).
  final String seatWs;

  bool get hasSeat => seatWs.isNotEmpty && token.isNotEmpty;
}

/// The read source for a bound world: the http facade only — an embed
/// never spawns a daemon (the attach law). [token] rides the
/// Authorization header when the facade is bearer-gated (a LAN bind);
/// loopback/no-auth facades pass none. Connection failures surface
/// at sample time (null), never as throws.
TraceSource sourceForBinding(
  final WorldBindingModel binding, {
  final String token = '',
}) => HttpTraceSource(
  base: Uri.parse(binding.endpoint),
  worldId: binding.worldId,
  headers: token.isEmpty ? const {} : {'Authorization': 'Bearer $token'},
);

/// Parses a user-added endpoint honestly: scheme + host required
/// (loopback or LAN — the OSS user decides what they connect to).
WorldBindingModel? parseManualBinding(final String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  final endpoint = '$uri';
  return WorldBindingModel(
    worldId: 'manual-${uri.host}-${uri.port}',
    endpoint: endpoint.endsWith('/') ? endpoint : '$endpoint/',
    displayName: '${uri.host}:${uri.port}',
  );
}
