import 'package:flutter/widgets.dart';

import 'ad_instance.dart';
import 'purchases_ads_base.dart';

final class PurchasesAdsService extends PurchasesAdsBase {
  // ignore: avoid_unused_constructor_parameters
  PurchasesAdsService(final BuildContext context);
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    onLoadingFailed();
  }

  @override
  Future<AdInstance> prepareAdInstance({required final AdUnitTuple unitIds}) {
    throw UnsupportedError('watchRewardedAd');
  }
}
