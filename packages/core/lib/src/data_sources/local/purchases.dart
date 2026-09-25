import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../../../core.dart';

class PurchasesLocalDataSourceImpl implements PurchasesLocalDataSource {
  PurchasesLocalDataSourceImpl(final BuildContext context)
    : db = context.read();
  final LocalDbI db;

  @override
  Future<PurchasesModel> receiveAdVideoReward(
    final AdVideoLengthType videoLength,
  ) async {
    final purchases = await getPurchases();
    final updatedPurchases = purchases.copyWith(
      daysOfSupporterLeft: purchases.daysOfSupporterLeft + 7,
    );
    await setPurchases(updatedPurchases);
    return increaseSupporterDaysCount();
  }

  @override
  Future<PurchasesModel> setPurchases(final PurchasesModel value) async {
    await db.setItem(
      value: value,
      key: SharedPreferencesKeys.purchases.name,
      toJson: (final v) => v.toJson(),
    );
    return value;
  }

  @override
  Future<PurchasesModel> getPurchases() async {
    final item = await db.getItem(
      key: SharedPreferencesKeys.purchases.name,
      fromJson: PurchasesModel.fromJson,
      defaultValue: PurchasesModel.empty,
    );
    return item;
  }

  @override
  Future<PurchasesModel> increaseSupporterDaysCount() async {
    final purchases = await getPurchases();
    if (!purchases.isActive) return purchases;

    final updatedPurchases = purchases.copyWith(
      supporterDaysCount: purchases.supporterDaysCount + 1,
    );
    return setPurchases(updatedPurchases);
  }

  @override
  Future<PurchasesModel> consumeSupporterDay() async {
    final purchases = await getPurchases();
    int daysLeft = purchases.daysOfSupporterLeft - 1;
    daysLeft = daysLeft < 0 ? 0 : daysLeft;
    final updatedPurchases = purchases.copyWith(daysOfSupporterLeft: daysLeft);
    return setPurchases(updatedPurchases);
  }

  @override
  Future<bool> verifyDayRecord() async {
    final millisecondsSinceEpoch = await db.getInt(
      key: SharedPreferencesKeys.supporterDayRecordMs.name,
    );
    final recordedDate = DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch,
    ).onlyDate;
    final isSameDay = recordedDate == todayDate;
    if (!isSameDay) {
      db.setInt(
        key: SharedPreferencesKeys.supporterDayRecordMs.name,
        value: todayDate.millisecondsSinceEpoch,
      );
    }
    return isSameDay;
  }

  @override
  Future<PurchasesModel> increaseUsedDaysCount() async {
    final purchases = await getPurchases();
    final updatedPurchases = purchases.copyWith(
      usedDaysCount: purchases.usedDaysCount + 1,
    );
    return setPurchases(updatedPurchases);
  }
}
