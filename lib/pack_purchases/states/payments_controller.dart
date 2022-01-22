part of pack_purchases;

PaymentsController createPaymentsController(
  final BuildContext context,
) =>
    PaymentsController(
      paymentsService: PaymentsService(),
    );

class PaymentsController extends ChangeNotifier implements Loadable {
  PaymentsController({
    required this.paymentsService,
  });
  final PaymentsService paymentsService;

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    log(Envs.revenueCatApiKey);
    if (paymentsService.paymentsNotAccessable) return;
    await Purchases.setup(Envs.revenueCatApiKey);
  }
}
