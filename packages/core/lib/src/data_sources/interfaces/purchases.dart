import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchasesRemoteDataSource {
  Future<void> verifySubscription(final ProductDetails details);
}
