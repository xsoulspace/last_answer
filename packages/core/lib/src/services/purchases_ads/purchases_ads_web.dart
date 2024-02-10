import 'package:flutter/widgets.dart';

import 'ad_instance.dart';
import 'purchases_ads_base.dart';

final class PurchasesAdsService extends PurchasesAdsBase {
  // ignore: avoid_unused_constructor_parameters
  PurchasesAdsService(final BuildContext context);

  /// https://yandex.ru/support/partner/web/units/types/rewarded.html
  @override
  Future<AdInstance> prepareAdInstance({required final String adUnitId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> onLoad() {
    throw UnimplementedError();
  }
}

final class AdInstanceYaWebImpl extends AdInstance {
  @override
  void dispose() {}

  @override
  Future<RewardModel> show() async => RewardModel(amount: 0, isRewarded: false);
}
