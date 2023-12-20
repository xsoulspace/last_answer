import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

class PurchasesRepository {
  PurchasesRepository({
    required final BuildContext context,
  }) : _remote = context.read();
  final PurchasesRemoteDataSource _remote;
  Future<bool> verifySubscription(final ProductDetails details) =>
      _remote.verifySubscription(details);
}
