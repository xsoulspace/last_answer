import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/pack_purchases/abstract/purchases_abstract.dart';
import 'package:lastanswer/pack_purchases/mobile_purchases/src/revenue_cat_payment_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

PaymentsControllerI createPaymentsController({
  required final BuildContext context,
  required final String appleKey,
  required final String googleKey,
}) =>
    PaymentsController(
      paymentsService: RevenueCatPaymentsService(
        appleKey: appleKey,
        googleKey: googleKey,
      ),
    );

class PaymentsController extends PaymentsControllerI {
  PaymentsController({
    required this.paymentsService,
  });
  final PaymentsServiceI<CustomerInfo, Offerings> paymentsService;
  @override
  bool get isPatronSubscription {
    switch (subscriptionType) {
      case SubscriptionTypes.free:
        return false;
      default:
        return true;
    }
  }

  CustomerInfo? customerInfo;
  Offerings? offerings;

  Package? get _annualSubscription => offerings?.current?.annual;

  @override
  String get annualSubscriptionTitle =>
      //TODO(arenukvern): translate
      'Subscribe - ${_annualSubscription?.product.priceString} / year';

  Package? get _monthlySubscription => offerings?.current?.monthly;
  //TODO(arenukvern): translate
  @override
  String get monthlySubscriptionTitle =>
      'Subscribe - ${_monthlySubscription?.product.priceString} / month';

  @override
  bool get paymentsAccessable => paymentsService.paymentsAccessable;

  @override
  Future<void> onLoad() async {
    if (paymentsService.paymentsNotAccessable) return;
    final key = paymentsService.paymentInitialKey;
    if (key.isEmpty) throw ArgumentError.value('key is not provided');

    try {
      await Purchases.setup(key);
      await Purchases.setDebugLogsEnabled(false);
      final effectiveCustomerInfo =
          customerInfo = await paymentsService.getPurchaserInfo();
      final allFeaturesEntitlment =
          effectiveCustomerInfo.entitlements.all['pro'];
      if (allFeaturesEntitlment != null && allFeaturesEntitlment.isActive) {
        subscriptionType = SubscriptionTypes.paidPatron;
      }

      offerings = await paymentsService.getOfferings();
    } on PlatformException catch (e) {
      // TODO(arenukvern): add log for errors
      if (kDebugMode) {
        print(e);
      }

      return;
    }
  }
}
