part of pack_purchases;

// TODO(antmalofeev): enable  when purchases will be released
const kPaymentsAccessable = kDebugMode;

class PaymentsService {
  bool get paymentsAccessable {
    if (!kPaymentsAccessable) return false;

    if (kIsWeb) return false;

    if (Platform.isIOS) {
      return Envs.revenueCatApiKeyAppleIsNotEmpty;
    } else if (Platform.isAndroid) {
      return Envs.revenueCatApiKeyGoogleIsNotEmpty;
    }

    return false;
  }

  String get paymentInitialKey {
    if (Platform.isIOS) {
      return Envs.revenueCatApiKeyApple;
    } else if (Platform.isAndroid) {
      return Envs.revenueCatApiKeyGoogle;
    }

    return '';
  }

  bool get paymentsNotAccessable => !paymentsAccessable;

  Future<PurchaserInfo> getPurchaserInfo() async {
    final purchaserInfo = await Purchases.getPurchaserInfo();
    print('${{"!!! purchaserInfo": purchaserInfo.toJson().toString()}}');

    return purchaserInfo;
  }

  Future<Offerings> getOfferings() async {
    final offerings = await Purchases.getOfferings();
    print('${{"!!! offerings": offerings.toJson().toString()}}');

    return offerings;
  }
}
