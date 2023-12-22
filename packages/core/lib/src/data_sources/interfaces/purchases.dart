import 'package:shared_models/shared_models.dart';

abstract class PurchasesRemoteDataSource {
  PurchasesRemoteDataSource._();
  Future<PurchaseModel?> verifyNativeMobilePurchase({
    required final ProductModelId productId,
    required final String verificationData,
  });
}
