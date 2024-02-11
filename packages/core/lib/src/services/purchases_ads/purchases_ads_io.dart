import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import '../../../core.dart';
import 'ad_instance.dart';
import 'purchases_ads_base.dart';

final class PurchasesAdsService extends PurchasesAdsBase {
  // ignore: avoid_unused_constructor_parameters
  PurchasesAdsService(final BuildContext context);
  final _instance = PlatformInfo.isNativeMobile
      ? PurchasesAdsServiceMobileYaImpl()
      : PurchasesAdsServiceDesktop();
  @override
  Future<AdInstance> prepareAdInstance({required final AdUnitTuple unitIds}) =>
      _instance.prepareAdInstance(unitIds: unitIds);
  @override
  Future<void> onLoad() {
    _instance.onLoad();
    return super.onLoad();
  }
}

final class PurchasesAdsServiceMobileYaImpl extends PurchasesAdsBase {
  late final Future<RewardedAdLoader> _adLoader;
  Completer<RewardedAd>? _adCompleter = Completer();

  @override
  Future<void> onLoad() async {
    await MobileAds.initialize();
    if (kDebugMode) {
      await MobileAds.setLogging(true);
      await MobileAds.setDebugErrorIndicator(true);
    }
    _adLoader = RewardedAdLoader.create(
      onAdLoaded: (final ad) => _adCompleter?.complete(ad),
      onAdFailedToLoad: (final error) {
        _adCompleter?.completeError(error);
        _adCompleter = null;
        // Ad failed to load with AdRequestError.
        // Attempting to load a new ad from the onAdFailedToLoad()
        //  method is strongly discouraged.
        if (kDebugMode) print(error);
        onLoadingFailed();
      },
    );
    return super.onLoad();
  }

  /// https://yandex.ru/support2/mobile-ads/en/dev/flutter/rewarded
  ///
  /// can look like 'R-M-$adUnitId-Y'
  @override
  Future<AdInstance> prepareAdInstance({
    required final AdUnitTuple unitIds,
  }) async {
    final adLoader = await _adLoader;
    Future<void> preload() => adLoader.loadAd(
          adRequestConfiguration: AdRequestConfiguration(
            adUnitId: unitIds.mobile,
          ),
        );
    Completer<RewardedAd>? adCompleter = _adCompleter;
    if (adCompleter == null) {
      _adCompleter = adCompleter = Completer();
      await preload();
    }
    final ad = await adCompleter.future;
    return AdInstanceYaMobileImpl(
      ad: ad,
      onDispose: () async {
        _adCompleter = Completer();
        await preload();
      },
    );
  }
}

final class PurchasesAdsServiceDesktop extends PurchasesAdsBase {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    onLoadingFailed();
  }

  @override
  Future<AdInstance> prepareAdInstance({required final AdUnitTuple unitIds}) {
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
  Future<AdRewardModel> show() async {
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
      return AdRewardModel(amount: amount, isRewarded: true);
    } else {
      return AdRewardModel(amount: 0, isRewarded: false);
    }
  }
}
