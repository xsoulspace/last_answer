import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

/// App-specific purchase flags (congrats-once flag).
class PurchaseFlagsLocalApi {
  PurchaseFlagsLocalApi({required this.localDb});
  final LocalDbI localDb;

  static const purchaseCongratsSeenKey = 'purchase_congrats_seen';

  static String _combinedKey(final PurchaseId purchaseId) =>
      '$purchaseCongratsSeenKey:$purchaseId';

  Future<bool> isPurchaseCongratsSeen({required final PurchaseId purchaseId}) =>
      localDb.getBool(key: _combinedKey(purchaseId));

  Future<void> setPurchaseCongratsSeen({
    required final PurchaseId purchaseId,
  }) => localDb.setBool(key: _combinedKey(purchaseId), value: true);

  Future<bool> shouldShowCongrats({
    required final PurchaseId purchaseId,
  }) async {
    final seen = await isPurchaseCongratsSeen(purchaseId: purchaseId);
    return !seen;
  }
}

abstract final class PaywallFlow {
  static const paywallPath = '/settings/paywall';

  static Future<void> pushPaywall(final BuildContext context) =>
      context.push(paywallPath);

  static Future<void> passPaywall(
    final BuildContext context, {
    final bool shouldRedirect = true,
  }) async {
    if (context.mounted && shouldRedirect && context.canPop()) {
      context.pop();
    }
  }

  static VoidCallback listenResolvePendingThenRecheck({
    required final BuildContext context,
  }) {
    final subscriptionStatus = context.read<SubscriptionStatusResource>();

    void listener() {
      if (!subscriptionStatus.isPendingConfirmation) {
        subscriptionStatus.removeListener(listener);
        unawaited(checkSubscriptionStatus(context));
      }
    }

    subscriptionStatus.addListener(listener);
    return () => subscriptionStatus.removeListener(listener);
  }

  static Future<void> checkSubscriptionStatus(
    final BuildContext context, {
    final bool shouldPopWithoutSubscription = true,
  }) async {
    final foundation = context.read<MonetizationFoundation>();
    final subscriptionStatus = context.read<SubscriptionStatusResource>();
    try {
      if (subscriptionStatus.isSubscribed && context.mounted) {
        if (context.canPop()) context.pop();
      } else if (shouldPopWithoutSubscription &&
          subscriptionStatus.isFree &&
          context.mounted &&
          context.canPop()) {
        // Stay on the paywall for free users who opened it intentionally.
        return;
      }
    } on Object catch (error, stackTrace) {
      debugPrint('PaywallFlow.checkSubscriptionStatus: $error');
      debugPrint('PaywallFlow.checkSubscriptionStatus: $stackTrace');
    } finally {
      unawaited(foundation.checkActiveSubscription());
    }
  }
}
