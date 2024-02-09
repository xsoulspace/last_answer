import 'ad_instance.dart';
import 'purchases_ads_base.dart';

final class PurchasesAdsService extends PurchasesAdsBase {
  PurchasesAdsService();

  /// https://yandex.ru/support/partner/web/units/types/rewarded.html
  @override
  Future<AdInstance> watchRewardedAd({required final String adUnitId}) {
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
  void show() {}
}
