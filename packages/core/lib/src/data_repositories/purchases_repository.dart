import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';

class PurchasesRepository {
  PurchasesRepository({
    required final BuildContext context,
  }) : _remote = context.read();
  final PurchasesRemoteDataSource _remote;
  Future<PurchaseActionModel?> verifyNativeMobilePurchase({
    required final IAPId productId,
    required final String verificationData,
    required final PurchasePaymentProvider provider,
  }) =>
      _remote.verifyNativeMobilePurchase(
        productId: productId,
        verificationData: verificationData,
        provider: provider,
      );
  Future<bool> receiveAdVideoReward({
    required final AdVideoLengthType videoLength,
  }) =>
      _remote.receiveAdVideoReward(videoLength);
}
