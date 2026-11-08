/// Plan v5 4a — the entitlement seam: ONE honest answer to "is this
/// user Pro?" — [ProEntitlement.isPro] is `subscribed OR dev-override`
/// and nothing else. The tier layer (tier_gate.dart) sits ABOVE the
/// platform-fact layer ([DeviceCapabilitySnapshot] and friends) and
/// never replaces it: a capability fact says what THIS device can host;
/// the entitlement says what this user may unlock. Both must answer.
///
/// Honesty laws:
/// - WITHOUT monetization DI the entitlement is FREE, never a crash —
///   hermetic surfaces and tests construct it with no subscription
///   resource and read `isPro == false`.
/// - The dev override is a PERSISTED device-local flag
///   (`lastanswer.entitlement.devPro`, SharedPreferences — the same
///   storage law as the world-binding store). It is a debug seam, not a
///   product state: release builds answer from the store.
/// - [refresh] re-reads the subscription resource; a missing store
///   provider degrades at the PURCHASE attempt (the paywall names the
///   absence), never by hiding the entitlement.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';

/// The Pro entitlement: `isSubscribed OR devOverride`.
class ProEntitlement extends ChangeNotifier {
  ProEntitlement({
    final SubscriptionStatusResource? subscriptionStatus,
    final Future<SharedPreferences> Function()? preferences,
  }) : _subscriptionStatus = subscriptionStatus,
       _preferences = preferences ?? SharedPreferences.getInstance {
    _subscriptionStatus?.addListener(_onSubscriptionChanged);
    unawaited(load());
  }

  /// The persisted dev-override key (SharedPreferences, device-local).
  static const devOverrideKey = 'lastanswer.entitlement.devPro';

  final SubscriptionStatusResource? _subscriptionStatus;
  final Future<SharedPreferences> Function() _preferences;

  bool _devOverride = false;
  bool _loaded = false;
  bool _disposed = false;

  /// Set once [setDevOverride] has spoken: a later-landing async
  /// [load] (the constructor's unawaited first read) never clobbers an
  /// explicit choice — last WRITER by intent, not by race.
  bool _explicitOverride = false;

  /// The store truth — FREE when monetization DI is absent (honesty
  /// law: no resource is no subscription, never a throw).
  bool get isSubscribed => _subscriptionStatus?.isSubscribed ?? false;

  /// The persisted debug seam (toggled from a debug surface via
  /// [setDevOverride]; absent prefs read as `false`).
  bool get devOverride => _devOverride;

  /// The one entitlement answer: `subscribed OR dev-override`.
  bool get isPro => isSubscribed || _devOverride;

  /// Whether [load] has settled (the override's first read is async).
  bool get isLoaded => _loaded;

  void _onSubscriptionChanged() => _safeNotify();

  /// The teardown race guard: an async [load]/[setDevOverride] may
  /// settle after dispose (the provider tree came down mid-read) —
  /// a late notify is dropped, never an assert.
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// Reads the persisted dev override. A prefs failure (missing plugin
  /// on an exotic platform) reads as `false` — free, never a crash.
  /// A settled load or an explicit [setDevOverride] stands: the first
  /// read wins once, the human's choice wins always.
  Future<void> load() async {
    if (_loaded || _explicitOverride) {
      _safeNotify();
      return;
    }
    var read = false;
    try {
      final prefs = await _preferences();
      read = prefs.getBool(devOverrideKey) ?? false;
    } on Object {
      read = false;
    }
    if (_loaded || _explicitOverride) {
      // The awaited read was overtaken while in flight — the newer
      // fact stands (never a late clobber).
      _safeNotify();
      return;
    }
    _devOverride = read;
    _loaded = true;
    _safeNotify();
  }

  /// Persists the dev override (the debug-surface seam) and notifies.
  Future<void> setDevOverride(final bool value) async {
    _explicitOverride = true;
    _devOverride = value;
    _loaded = true;
    _safeNotify();
    try {
      final prefs = await _preferences();
      await prefs.setBool(devOverrideKey, value);
    } on Object {
      // The in-memory override stands for this session; persistence is
      // best-effort — a failed write never fakes a product state.
    }
  }

  /// Re-reads the subscription resource and notifies watchers. The
  /// store's own truth lives in [SubscriptionStatusResource]; this is
  /// the seam a surface calls after a purchase/restore round-trip.
  void refresh() => _safeNotify();

  @override
  void dispose() {
    _disposed = true;
    _subscriptionStatus?.removeListener(_onSubscriptionChanged);
    super.dispose();
  }
}
