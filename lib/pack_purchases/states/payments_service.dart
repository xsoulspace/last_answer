part of pack_purchases;

class PaymentsService {
  bool get paymentsAccessable =>
      // TODO(antmalofeev): remove kDebugMode when purchases will be released
      kDebugMode &&
      ((Platform.isIOS || Platform.isMacOS || Platform.isAndroid) &&
          !kIsWeb &&
          Envs.revenueCatApiKeyAppleIsNotEmpty &&
          Envs.revenueCatApiKeyGoogleIsNotEmpty);
  bool get paymentsNotAccessable => !paymentsAccessable;

  // Future<PurchaserInfo> getPurchaserInfo() async {
  //   final purchaserInfo = await Purchases.getPurchaserInfo();
  //   print('${{"!!! purchaserInfo": purchaserInfo.toJson().toString()}}');

  //   return purchaserInfo;
  // }

  // Future<Offerings> getOfferings() async {
  //   final offerings = await Purchases.getOfferings();
  //   print('${{"!!! offerings": offerings.toJson().toString()}}');

  //   return offerings;
  // }
}
