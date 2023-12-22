import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

class PurchasesRemoteDataSourceServerpodImpl
    implements PurchasesRemoteDataSource {
  PurchasesRemoteDataSourceServerpodImpl({
    required this.client,
  });
  final RemoteClientServerpodImpl client;
  @override
  Future<PurchaseModel?> verifyNativeMobilePurchase({
    required final ProductModelId productId,
    required final String verificationData,
  }) async {
    // client.
    return null;
  }
}
