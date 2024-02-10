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
  Future<void> onLoad() {}
}

final class AdInstanceYaWebImpl extends AdInstance {
  @override
  void dispose() {}

  /// https://yandex.ru/support/partner/web/units/types/rewarded.html
  @override
  Future<RewardModel> show() async {
// window.yaContextCb.push(() => {
//       if (Ya.Context.AdvManager.getPlatform() === 'desktop') {
//         // вызов блока Rewarded для десктопной версии
//         Ya.Context.AdvManager.render({
//           blockId: 'R-A-588461-68',
//           type: 'rewarded',
//           platform: 'desktop',
//           onRewarded: (isRewarded) => {
//               if (isRewarded) {
//                   // условие получения награды выполнено
//               } else {
//                   // условие получения награды не выполнено
//               }
//           }
//         });
//       } else {
//         // вызов блока Rewarded для мобильной версии
//         Ya.Context.AdvManager.render({
//           blockId: 'R-A-588461-69',
//           type: 'rewarded',
//           platform: 'touch',
//           onRewarded: (isRewarded) => {
//               if (isRewarded) {
//                   // условие получения награды выполнено
//               } else {
//                   // условие получения награды не выполнено
//               }
//           }
//         });
//       }
//   });

    return RewardModel(amount: 0, isRewarded: false);
  }
}
