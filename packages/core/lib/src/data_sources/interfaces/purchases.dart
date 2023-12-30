import 'package:shared_models/shared_models.dart';

abstract class PurchasesRemoteDataSource {
  PurchasesRemoteDataSource._();
  Future<PurchaseModel?> verifyNativeMobilePurchase({
    required final IAPId productId,
    required final String verificationData,
    required final PurchasePaymentProvider provider,
  });
}
