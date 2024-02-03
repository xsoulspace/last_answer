import 'package:flutter/cupertino.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';
import '../data_sources/remote/remote.dart';

class PurchasesRepository {
  PurchasesRepository(final BuildContext context)
      : _remote = PurchasesRemoteDataSourceServerpodImpl(
          client: RemoteClient.ofContextAsServerpodImpl(context),
        );
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
