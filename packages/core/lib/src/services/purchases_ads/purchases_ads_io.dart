import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import '../../../core.dart';
import 'ad_instance.dart';
import 'purchases_ads_base.dart';

final class PurchasesAdsService extends PurchasesAdsBase {
  PurchasesAdsService();
  final _instance = PlatformInfo.isNativeMobile
      ? PurchasesAdsServiceMobileYaImpl()
      : PurchasesAdsServiceDesktop();
  @override
  Future<AdInstance> watchRewardedAd({required final String adUnitId}) =>
      _instance.watchRewardedAd(adUnitId: adUnitId);
  @override
  Future<void> onLoad() => _instance.onLoad();
}

final class PurchasesAdsServiceMobileYaImpl extends PurchasesAdsBase {
  late final Future<RewardedAdLoader> _adLoader;
  bool _isLoaded = false;
  @override
  Future<void> onLoad() async {
    await MobileAds.initialize();
    if (kDebugMode) {
      await MobileAds.setLogging(true);
      await MobileAds.setDebugErrorIndicator(true);
    }
    _adLoader = _createRewardedAdLoader();
    _isLoaded = true;
  }

  Future<RewardedAdLoader> _createRewardedAdLoader() => RewardedAdLoader.create(
        onAdLoaded: (final ad) {},
        onAdFailedToLoad: (final error) {
          // Ad failed to load with AdRequestError.
          // Attempting to load a new ad from the onAdFailedToLoad()
          //  method is strongly discouraged.
          if (kDebugMode) print(error);
          _isLoaded = false;
        },
      );

  /// https://yandex.ru/support2/mobile-ads/en/dev/flutter/rewarded
  @override
  Future<AdInstance> watchRewardedAd({required final String adUnitId}) async {
    final adLoader = await _adLoader;
    await adLoader.loadAd(
      adRequestConfiguration: AdRequestConfiguration(
        adUnitId: 'R-M-$adUnitId-Y',
      ),
    );
    
    return AdInstanceYaMobileImpl(ad: );
  }
}

final class PurchasesAdsServiceDesktop extends PurchasesAdsBase {
  @override
  Future<void> onLoad() {
    // TODO(arenukvern): implement,
    throw UnimplementedError();
  }

  @override
  Future<AdInstance> watchRewardedAd({required final String adUnitId}) {
    // TODO(arenukvern): implement,
    throw UnimplementedError();
  }
}

final class AdInstanceYaMobileImpl extends AdInstance {
  AdInstanceYaMobileImpl({
    required this.ad,
    required this.onDispose,
  });
  final RewardedAd ad;
  final VoidCallback onDispose;
  @override
  Future<void> dispose() async {
    // Destroy the ad so you don't show the ad a second time.
    await ad.destroy();
    onDispose();
  }

  @override
  Future<RewardModel> show() async {
    await ad.setAdEventListener(
      eventListener: RewardedAdEventListener(
        onAdFailedToShow: (final e) => dispose(),
        onAdDismissed: dispose,
      ),
    );
    await ad.show();
    final reward = await ad.waitForDismiss();
    final amount = reward?.amount ?? 0;
    if (amount >= 0) {
      return RewardModel(amount: amount, isRewarded: true);
    } else {
      return RewardModel(amount: 0, isRewarded: false);
    }
  }
}
