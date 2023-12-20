import 'package:in_app_purchase/in_app_purchase.dart';

import '../interfaces/purchases.dart';

class PurchasesRemoteDataSourceServerpodImpl
    implements PurchasesRemoteDataSource {
  @override
  Future<bool> verifySubscription(final ProductDetails details) async {
    // TODO(username): unimplemented
    throw UnimplementedError('unimplemented error');
    return true;
  }
}
