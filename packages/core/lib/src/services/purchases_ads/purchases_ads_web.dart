// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html';

import 'package:flutter/widgets.dart';

import 'ad_instance.dart';
import 'purchases_ads_base.dart';
import 'yandex/yandex.dart';

final class PurchasesAdsService extends PurchasesAdsBase {
  // ignore: avoid_unused_constructor_parameters
  PurchasesAdsService(final BuildContext context);

  /// https://yandex.ru/support/partner/web/units/types/rewarded.html
  @override
  Future<AdInstance> prepareAdInstance({
    required final AdUnitTuple unitIds,
  }) async =>
      AdInstanceYaWebImpl(unitIds: unitIds);

  @override
  Future<void> onLoad() async {}
}

final class AdInstanceYaWebImpl extends AdInstance {
  AdInstanceYaWebImpl({required this.unitIds});
  final AdUnitTuple unitIds;
  @override
  void dispose() {}

  /// https://yandex.ru/support/partner/web/units/types/rewarded.html
  @override
  Future<AdRewardModel> show() async {
    final completer = Completer<bool>();

    /// [platform] = 'desktop' or 'touch'
    void render({
      required final String unitId,
      required final String platform,
    }) =>
        Ya.Context.AdvManager.render(
          YaContextAdvManagerRender(
            blockId: unitId,
            onRewarded: completer.complete,
            platform: platform,
            darkTheme: unitIds.isDarkMode,
            type: 'rewarded',
          ),
        );

    window.yaContextCb.push(() {
      switch (Ya.Context.AdvManager.getPlatform()) {
        case 'desktop':
          render(unitId: unitIds.desktop, platform: 'desktop');
        default:
          render(unitId: unitIds.mobile, platform: 'touch');
      }
    });
    final isRewarded = await completer.future;
    return AdRewardModel(amount: 1, isRewarded: isRewarded);
  }
}
