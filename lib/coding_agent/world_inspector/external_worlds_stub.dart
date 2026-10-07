// ignore_for_file: lines_longer_than_80_chars, implementation_imports

/// WEB STUB — the external-worlds attach on a platform with no dart:io.
/// The pane (and its debug verbs) import this pair through a conditional
/// import; web answers honest absence, never a compile error.
library;

import 'package:core/core.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';
import 'package:xsoulspace_agentic_harness_inspector/src/source.dart';
import 'package:xsoulspace_agentic_host/src/world_manifest.dart'
    show WorldManifest;

/// No filesystem scan on web → no attachable external world.
TraceSource? resolveExternal({final String? worldId}) => null;

// ADR 0072 — the paired-worlds route is io-only (SharedPreferences
// works on web, but no paired world is reachable from a browser
// sandbox anyway): honest absence, same as the manifest scan.
Future<TraceSource?> resolveExternalAsync({final String? worldId}) async =>
    null;

Future<List<Map<String, Object?>>> buildWorldAnnouncement() async =>
    const [];

Future<Map<String, Object?>?> buildPairingApplicationData() async => null;

Future<List<Map<String, Object?>>> pairedWorldsJson() async => const [];

/// No live manifests on web.
List<WorldManifest> liveWorlds() => const [];

/// No filesystem discovery on web — the manual-endpoint route (web-safe
/// by construction) is the connect surface there.
Future<List<DiscoveredWorld>> discoverWorlds() async => const [];

/// No device-local roster to re-resolve against on web.
Future<DiscoveredWorld?> rediscover(final WorldBindingModel binding) async =>
    null;
