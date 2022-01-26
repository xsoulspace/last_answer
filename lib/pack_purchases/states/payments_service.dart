part of pack_purchases;

class PaymentsService {
  bool get paymentsAccessable =>
      Envs.revenueCatApiKeyAppleIsNotEmpty &&
      Envs.revenueCatApiKeyGoogleIsNotEmpty &&
      (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) &&
      !kIsWeb;
  bool get paymentsNotAccessable => !paymentsAccessable;

  Future<PurchaserInfo> getPurchaserInfo() async {
    final purchaserInfo = await Purchases.getPurchaserInfo();
    log(purchaserInfo.toJson().toString());

    return purchaserInfo;
  }

  Future<Offerings> getOfferings() async {
    final offerings = await Purchases.getOfferings();
    log(offerings.toJson().toString());

    return offerings;
  }
}
