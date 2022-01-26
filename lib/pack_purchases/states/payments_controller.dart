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

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    if (paymentsService.paymentsNotAccessable) return;
    String key = '';
    if (Platform.isIOS) {
      key = Envs.revenueCatApiKeyApple;
    } else if (Platform.isAndroid) {
      key = Envs.revenueCatApiKeyGoogle;
    }
    if (key.isEmpty) throw ArgumentError.value('key is not provided');
    try {
      await Purchases.setup(key);
      await Purchases.setDebugLogsEnabled(true);

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
