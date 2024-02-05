import 'ad_instance.dart';
import 'purchases_ads_base.dart';

final class PurchasesAdsService extends PurchasesAdsBase {
  @override
  Future<void> onLoad() async {}

  @override
  Future<AdInstance> watchRewardedAd({required final String adUnitId}) {
    throw UnsupportedError('watchRewardedAd');
  }
}
