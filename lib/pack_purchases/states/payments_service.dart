part of pack_purchases;

class PaymentsService implements Loadable {
  bool get paymentsAccessable =>
      Envs.revenueCatApiKeyIsNotEmpty &&
      (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) &&
      !kIsWeb;
  bool get paymentsNotAccessable => !paymentsAccessable;
  @override
  Future<void> onLoad({required final BuildContext context}) async {
    if (paymentsNotAccessable) return;
    await Purchases.setup(Envs.revenueCatApiKey);
  }
}
