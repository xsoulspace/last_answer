/// The persisted world choice (plan v5 1c — the binding is an
/// IMPLEMENTATION DETAIL): the user's last connect/disconnect decision
/// survives the leaf swap, keyed by the doc/workspace identity the
/// caller owns. Auto-resolution on open reads this store; the user is
/// never asked to re-pick a world they already picked.
///
/// Three honest states, never collapsed into each other:
/// - [NoPersistedWorldBinding] — nothing was ever chosen (the embedded
///   default path, by absence);
/// - [PersistedEmbeddedWorld] — an EXPLICIT disconnect: the user chose
///   the embedded world and that choice persists (never re-attached by
///   a stale binding);
/// - [PersistedExternalWorld] — the last picked external world, the
///   auto-attach candidate (the caller still owes an honest
///   reachability answer before attaching — a persisted binding is a
///   choice, not a liveness proof).
///
/// Storage law: SharedPreferences, device-local, one JSON string per
/// key ([WorldBindingModel] rides its freezed `toJson`/`fromJson`). The
/// bearer token NEVER rides the persisted payload — device-local trust
/// re-resolves through discovery at attach time (the same law the doc
/// payload's `worldBinding` follows). Corrupt values read as honest
/// absence, never a throw.
library;

import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:core/core.dart';
import 'package:lastanswer/coding_agent/world_inspector/external_worlds_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/world_inspector/external_worlds_io.dart'
    as external_worlds;
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What [WorldBindingStore.load] found for one scope key.
sealed class PersistedWorldBinding {
  const PersistedWorldBinding();
}

/// Nothing was ever persisted for the key — the embedded default.
final class NoPersistedWorldBinding extends PersistedWorldBinding {
  const NoPersistedWorldBinding();
}

/// An explicit disconnect was persisted: embedded, by user choice.
final class PersistedEmbeddedWorld extends PersistedWorldBinding {
  const PersistedEmbeddedWorld();
}

/// A persisted external world — the auto-attach candidate.
final class PersistedExternalWorld extends PersistedWorldBinding {
  const PersistedExternalWorld(this.binding);

  final WorldBindingModel binding;
}

/// The static persistence seam over SharedPreferences (the
/// `world_seat.human_subject.v1` pattern: `setMockInitialValues` is the
/// test seam, no DI ceremony).
abstract final class WorldBindingStore {
  static const String _keyPrefix = 'lastanswer.world_inspector.binding.v1.';

  static String _key(final String docKey) =>
      '$_keyPrefix${Uri.encodeComponent(docKey)}';

  /// The persisted choice for [docKey] (the doc/workspace identity the
  /// caller owns). Corrupt or undecodable values answer honest absence.
  static Future<PersistedWorldBinding> load({
    required final String docKey,
  }) async {
    final raw = (await SharedPreferences.getInstance()).getString(_key(docKey));
    if (raw == null || raw.isEmpty) return const NoPersistedWorldBinding();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const NoPersistedWorldBinding();
      }
      return switch (decoded['state']) {
        'embedded' => const PersistedEmbeddedWorld(),
        'world' when decoded['binding'] is Map => PersistedExternalWorld(
          WorldBindingModel.fromJson(
            Map<String, dynamic>.from(decoded['binding'] as Map),
          ),
        ),
        _ => const NoPersistedWorldBinding(),
      };
    } on Object catch (_) {
      return const NoPersistedWorldBinding();
    }
  }

  /// Persists an explicit world pick (the connect affordance's choice).
  static Future<void> saveWorld({
    required final String docKey,
    required final WorldBindingModel binding,
  }) async {
    await (await SharedPreferences.getInstance()).setString(
      _key(docKey),
      jsonEncode({'state': 'world', 'binding': binding.toJson()}),
    );
  }

  /// Persists an explicit disconnect: embedded stays embedded across
  /// remounts (never a silent re-attach of the previous world).
  static Future<void> saveEmbedded({required final String docKey}) async {
    await (await SharedPreferences.getInstance()).setString(
      _key(docKey),
      jsonEncode({'state': 'embedded'}),
    );
  }
}

/// The auto-resolution answer for one persisted choice (the mount-time
/// read: what the view attaches WITHOUT asking the user to re-pick).
sealed class WorldBindingResolution {
  const WorldBindingResolution();
}

/// The embedded world: nothing persisted, or an explicit disconnect —
/// the default path, honestly chosen either way.
final class EmbeddedWorldResolution extends WorldBindingResolution {
  const EmbeddedWorldResolution();
}

/// The persisted world answered a sample: attach it.
final class AttachWorldResolution extends WorldBindingResolution {
  const AttachWorldResolution(this.binding);

  final WorldBindingModel binding;
}

/// The persisted world is unreachable: the honest degrade is the
/// embedded world PLUS a quiet note naming what was lost and the arm
/// command — never a crash, never a silent lie.
final class UnreachableWorldResolution extends WorldBindingResolution {
  const UnreachableWorldResolution(this.binding);

  final WorldBindingModel binding;
}

/// Resolves the persisted choice for [docKey] into an attach answer.
/// [isReachable] is the test seam (a scripted probe); the default is
/// the real http facade sample ([worldBindingReachable]) — unless the
/// global [debugReachabilityOverride] is set, which exists because
/// `testWidgets` installs a hermetic HTTP override (every client
/// request 400s), so a WIDGET leg can never ride the real transport
/// (the transport has its own coverage in `world_binding_http_test`).
Future<WorldBindingResolution> resolvePersistedWorldBinding({
  required final String docKey,
  final Future<bool> Function(WorldBindingModel binding)? isReachable,
}) async {
  final persisted = await WorldBindingStore.load(docKey: docKey);
  final binding = switch (persisted) {
    PersistedExternalWorld(:final binding) => binding,
    _ => null,
  };
  if (binding == null) return const EmbeddedWorldResolution();
  final reachable =
      await (isReachable ?? debugReachabilityOverride ?? worldBindingReachable)(
        binding,
      );
  return reachable
      ? AttachWorldResolution(binding)
      : UnreachableWorldResolution(binding);
}

/// The widget-test seam for the reachability probe (see
/// [resolvePersistedWorldBinding]); null in production, always.
@visibleForTesting
Future<bool> Function(WorldBindingModel binding)? debugReachabilityOverride;

/// The honest default reachability probe: re-resolve the device-local
/// token through discovery (the persisted payload never carries it),
/// then take ONE facade sample. A dead facade samples null (never a
/// throw — the read-rung law); a hung facade is bounded by the timeout.
Future<bool> worldBindingReachable(final WorldBindingModel binding) async {
  try {
    final world = await external_worlds.rediscover(binding);
    final trace = await sourceForBinding(
      binding,
      token: world?.token ?? '',
    ).sample().timeout(const Duration(seconds: 4));
    return trace != null;
  } on Object catch (_) {
    return false; // unreachable is honest absence, never a crash
  }
}
