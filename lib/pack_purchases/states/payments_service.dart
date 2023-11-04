class PaymentsService {
  bool get paymentsAccessable => false;
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
