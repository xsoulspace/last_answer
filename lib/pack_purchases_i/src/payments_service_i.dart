part of pack_purchases_i;

// TODO(antmalofeev): enable  when purchases will be released
const kPaymentsAccessable = kDebugMode;

abstract class PaymentsServiceI<TPurchaserInfo, TOfferings> {
  bool get paymentsAccessable;

  String get paymentInitialKey;

  bool get paymentsNotAccessable => !paymentsAccessable;

  Future<TPurchaserInfo> getPurchaserInfo();

  Future<TOfferings> getOfferings();
}
