part of pack_purchases;

PaymentsController createPaymentsController(
  final BuildContext context,
) =>
    PaymentsController(
      paymentsService: PaymentsService(),
    );

enum SubscriptionTypes {
  free,
  paidPro,
  advertisementPro,
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

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    if (paymentsService.paymentsNotAccessable) return;
    await Purchases.setup(Envs.revenueCatApiKey);
  }
}
