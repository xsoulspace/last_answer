import 'package:shared_models/shared_models.dart';

abstract class PurchasesRemoteDataSource {
  PurchasesRemoteDataSource._();
  Future<PurchaseActionModel?> verifyNativeMobilePurchase({
    required final IAPId productId,
    required final String verificationData,
    required final PurchasePaymentProvider provider,
  });
  Future<PurchasesModel> mergeLocalPurchases(final PurchasesModel purchase);
  Future<PurchasesModel> getPurchases();
}

abstract class PurchasesLocalDataSource {
  PurchasesLocalDataSource._();
  Future<PurchasesModel> receiveAdVideoReward(
    final AdVideoLengthType videoLength,
  );
  Future<PurchasesModel> getPurchases();
  Future<bool> verifyDayRecord();
  Future<PurchasesModel> increaseUsedDaysCount();
  Future<PurchasesModel> setPurchases(final PurchasesModel value);
  Future<PurchasesModel> increaseSupporterDaysCount();
  Future<PurchasesModel> consumeSupporterDay();
}
