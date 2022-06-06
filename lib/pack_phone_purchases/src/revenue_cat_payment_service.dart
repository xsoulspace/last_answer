import 'package:flutter/foundation.dart';
import 'package:lastanswer/pack_purchases_i/pack_purchases_i.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:universal_io/io.dart';

class RevenueCatPaymentsService
    implements PaymentsServiceI<PurchaserInfo, Offerings> {
  RevenueCatPaymentsService({
    required this.appleKey,
    required this.googleKey,
  });
  final String appleKey;
  final String googleKey;
  @override
  bool get paymentsAccessable {
    if (!kPaymentsAccessable) return false;

    if (kIsWeb) return false;

    if (Platform.isIOS) {
      return appleKey.isNotEmpty;
    } else if (Platform.isAndroid) {
      return googleKey.isNotEmpty;
    }

    return false;
  }

  @override
  String get paymentInitialKey {
    if (Platform.isIOS) {
      return appleKey;
    } else if (Platform.isAndroid) {
      return googleKey;
    }

    return '';
  }

  @override
  bool get paymentsNotAccessable => !paymentsAccessable;

  @override
  Future<PurchaserInfo> getPurchaserInfo() async {
    final purchaserInfo = await Purchases.getPurchaserInfo();
    print('${{"!!! purchaserInfo": purchaserInfo.toJson().toString()}}');

    return purchaserInfo;
  }

  @override
  Future<Offerings> getOfferings() async {
    final offerings = await Purchases.getOfferings();
    print('${{"!!! offerings": offerings.toJson().toString()}}');

    return offerings;
  }
}
