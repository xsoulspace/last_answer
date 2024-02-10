import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';
import '../data_sources/remote/remote.dart';

class PurchasesRepository {
  PurchasesRepository(final BuildContext context)
      : _remoteUserNotifier = context.read(),
        _remote = PurchasesRemoteDataSourceServerpodImpl(
          client: RemoteClient.ofContextAsServerpodImpl(context),
        ),
        _local = PurchasesLocalDataSourceImpl(context);
  final PurchasesRemoteDataSource _remote;
  final PurchasesLocalDataSource _local;
  final RemoteUserNotifier _remoteUserNotifier;
  bool get _isAuthorized => _remoteUserNotifier.isAuthorized;
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

  Future<PurchasesModel> receiveAdVideoReward({
    final AdVideoLengthType videoLength = AdVideoLengthType.s,
  }) =>
      _local.receiveAdVideoReward(videoLength);

  Future<PurchasesModel> getRemotePurchases() => _remote.getPurchases();
  Future<PurchasesModel> getLocalPurchases() => _local.getPurchases();
  Future<PurchasesModel> mergePurchases({
    required final PurchasesModel localPurchases,
  }) async {
    final remotePurchases = await getRemotePurchases();
    PurchasesModel updatedPurchase = remotePurchases.mergeWith(localPurchases);
    updatedPurchase = await _remote.mergeLocalPurchases(updatedPurchase);
    return _local.setPurchases(updatedPurchase);
  }

  Future<PurchasesModel> recordNewDay() async {
    final isRecorded = await _local.verifyDayRecord();
    if (isRecorded) return _local.getPurchases();

    await _local.consumeSupporterDay();
    PurchasesModel purchases = await _local.increaseSupporterDaysCount();
    if (_isAuthorized) {
      purchases = await _remote.mergeLocalPurchases(purchases);
    }
    return purchases;
  }
}
