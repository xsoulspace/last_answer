import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_purchases/states/payments_service.dart';

PaymentsController createPaymentsController(
  final BuildContext context,
) =>
    PaymentsController(
      paymentsService: PaymentsService(),
    );

enum SubscriptionTypes {
  free,
  paidPatron,
  advertisementPatron,
}

class PaymentsController extends ChangeNotifier implements Loadable {
  PaymentsController({
    required this.paymentsService,
  });
  final PaymentsService paymentsService;
  SubscriptionTypes subscriptionType = SubscriptionTypes.free;
  bool get isPatronSubscription => switch (subscriptionType) {
        SubscriptionTypes.free => false,
        SubscriptionTypes.advertisementPatron ||
        SubscriptionTypes.paidPatron =>
          true
      };

  // PurchaserInfo? purchaserInfo;
  // Offerings? offerings;

  // Package? get annualSubscription => offerings?.current?.annual;

  String get annualSubscriptionTitle => '';
  // TODO(Arenukvern): translate
  // 'Subscribe - ${annualSubscription?.product.priceString} / year';

  // Package? get monthlySubscription => offerings?.current?.monthly;
  // TODO(arenukvern): translate
  String get monthlySubscriptionTitle => '';
  // 'Subscribe - ${monthlySubscription?.product.priceString} / month';

  bool get paymentsAccessable => paymentsService.paymentsAccessable;

  @override
  Future<void> onLoad() async {
    if (paymentsService.paymentsNotAccessable) return;
  }
}
