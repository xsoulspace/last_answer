part of pack_purchases;

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
  bool get isPatronSubscription {
    switch (subscriptionType) {
      case SubscriptionTypes.free:
        return false;
      default:
        return true;
    }
  }

  PurchaserInfo? purchaserInfo;
  Offerings? offerings;

  Package? get annualSubscription => offerings?.current?.annual;

  String get annualSubscriptionTitle =>
      //TODO(arenukvern): translate
      'Subscribe - ${annualSubscription?.product.priceString} / year';

  Package? get monthlySubscription => offerings?.current?.monthly;
  //TODO(arenukvern): translate
  String get monthlySubscriptionTitle =>
      'Subscribe - ${monthlySubscription?.product.priceString} / month';

  bool get paymentsAccessable => paymentsService.paymentsAccessable;

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    if (paymentsService.paymentsNotAccessable) return;
    final key = paymentsService.paymentInitialKey;
    if (key.isEmpty) throw ArgumentError.value('key is not provided');

    try {
      await Purchases.setup(key);
      await Purchases.setDebugLogsEnabled(false);
      final effectivePurchaserInfo =
          purchaserInfo = await paymentsService.getPurchaserInfo();
      final allFeaturesEntitlment =
          effectivePurchaserInfo.entitlements.all['pro'];
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
