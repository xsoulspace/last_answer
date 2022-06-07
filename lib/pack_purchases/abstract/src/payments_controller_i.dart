import 'package:flutter/material.dart';
import 'package:lastanswer/pack_core/pack_core.dart';

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
  Future<void> onLoad({required final BuildContext context}) async {}
}
