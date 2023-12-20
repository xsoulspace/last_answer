import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchasesRemoteDataSource {
  PurchasesRemoteDataSource._();
  Future<bool> verifySubscription(final ProductDetails details);
}
