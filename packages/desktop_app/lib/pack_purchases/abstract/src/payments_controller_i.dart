import 'package:flutter/material.dart';
import 'package:life_hooks/life_hooks.dart';

enum SubscriptionTypes {
  free,
  paidPatron,
  advertisementPatron,
}

abstract class PaymentsControllerI extends ChangeNotifier implements Loadable {
  SubscriptionTypes subscriptionType = SubscriptionTypes.free;
  bool get isPatronSubscription {
    switch (subscriptionType) {
      case SubscriptionTypes.free:
        return false;
      default:
        return true;
    }
  }

  String get annualSubscriptionTitle;
  String get monthlySubscriptionTitle;
  bool get paymentsAccessable;
  @override
  Future<void> onLoad() async {}
}
