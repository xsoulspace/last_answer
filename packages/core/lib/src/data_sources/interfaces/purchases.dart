import 'package:shared_models/shared_models.dart';

abstract class PurchasesRemoteDataSource {
  PurchasesRemoteDataSource._();
  Future<PurchaseActionModel?> verifyNativeMobilePurchase({
    required final IAPId productId,
    required final String verificationData,
    required final PurchasePaymentProvider provider,
  });
  Future<bool> receiveAdVideoReward(final int videoLength);
}
