/// Plan v5 4a — the entitlement seam's laws, pinned:
/// - `isPro == isSubscribed || devOverride` and nothing else;
/// - WITHOUT monetization DI the entitlement is FREE, never a crash;
/// - the dev override persists (SharedPreferences round-trip) under the
///   named key `lastanswer.entitlement.devPro`;
/// - the subscription resource is listened to (a store flip notifies);
/// - `refresh()` re-reads and notifies.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/entitlement/pro_entitlement.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProEntitlement — the one answer', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('without monetization DI it is FREE, never a crash', () async {
      final entitlement = ProEntitlement();
      await entitlement.load();
      expect(entitlement.isSubscribed, isFalse);
      expect(entitlement.devOverride, isFalse);
      expect(entitlement.isPro, isFalse);
      expect(entitlement.isLoaded, isTrue);
      entitlement.dispose();
    });

    test('a subscribed store resource makes it Pro', () async {
      final status = SubscriptionStatusResource()
        ..set(SubscriptionStatus.subscribed);
      final entitlement = ProEntitlement(subscriptionStatus: status);
      await entitlement.load();
      expect(entitlement.isSubscribed, isTrue);
      expect(entitlement.isPro, isTrue);

      // The seam listens: a store flip is an entitlement flip.
      var notified = 0;
      entitlement.addListener(() => notified++);
      status.set(SubscriptionStatus.free);
      expect(notified, 1);
      expect(entitlement.isPro, isFalse);
      entitlement.dispose();
    });

    test('the dev override alone makes it Pro (the debug seam)', () async {
      final entitlement = ProEntitlement();
      await entitlement.load();
      expect(entitlement.isPro, isFalse);
      await entitlement.setDevOverride(true);
      expect(entitlement.isPro, isTrue);
      expect(entitlement.devOverride, isTrue);
      entitlement.dispose();
    });

    test('the dev override persists under the named key (round-trip)',
        () async {
      final first = ProEntitlement();
      await first.load();
      await first.setDevOverride(true);
      first.dispose();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ProEntitlement.devOverrideKey), isTrue);

      // A fresh instance re-reads the persisted flag.
      final second = ProEntitlement();
      await second.load();
      expect(second.devOverride, isTrue);
      expect(second.isPro, isTrue);
      second.dispose();
    });

    test('refresh() notifies (watchers re-read the live resource)', () async {
      final status = SubscriptionStatusResource();
      final entitlement = ProEntitlement(subscriptionStatus: status);
      await entitlement.load();
      var notified = 0;
      entitlement.addListener(() => notified++);
      entitlement.refresh();
      expect(notified, 1);

      status.set(SubscriptionStatus.subscribed);
      entitlement.refresh();
      expect(entitlement.isPro, isTrue);
      entitlement.dispose();
    });

    test('a prefs failure reads as free, never a throw', () async {
      final entitlement = ProEntitlement(
        preferences: () async => throw Exception('no plugin here'),
      );
      await entitlement.load();
      expect(entitlement.devOverride, isFalse);
      expect(entitlement.isPro, isFalse);
      expect(entitlement.isLoaded, isTrue);
      entitlement.dispose();
    });
  });
}
