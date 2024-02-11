import 'package:core_server_client/core_server_client.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

class PurchasesRemoteDataSourceServerpodImpl
    implements PurchasesRemoteDataSource {
  PurchasesRemoteDataSourceServerpodImpl({
    required this.client,
  });
  final RemoteClientServerpodImpl client;
  Client get _client => client.client;

  @override
  Future<PurchaseActionModel?> verifyNativeMobilePurchase({
    required final IAPId productId,
    required final String verificationData,
    required final PurchasePaymentProvider provider,
  }) async {
    // TODO(arenukvern): unimplemented
    throw UnimplementedError('unimplemented error');
  }

  @override
  Future<PurchasesModel> getPurchases() {
    throw UnimplementedError();
  }

  @override
  Future<PurchasesModel> mergeLocalPurchases(final PurchasesModel purchase) {
    throw UnimplementedError();
  }
}
