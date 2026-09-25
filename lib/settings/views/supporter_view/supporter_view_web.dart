import 'package:lastanswer/common_imports.dart';

class SupportAppView extends StatelessWidget {
  const SupportAppView({super.key});

  @override
  Widget build(final BuildContext context) {
    final purhasesNotifier = context.watch<PurchasesNotifier>();
    final adsNotifier = context.watch<AdsNotifier>();
    // final purchasesAdsService = context.watch<PurchasesAdsService>();
    // final isAdLoaded = purchasesAdsService.isLoaded;
    final l10n = context.l10n;
    return const SizedBox();
    // return SupportAppBaseView(
    //   children: purhasesNotifier.isAdSupported
    //       ? [
    //           Text(l10n.adPleaseNote),
    //           const Gap(24),
    //           if (adsNotifier.isAllowedToWatchRewarded)
    //             FilledButton.tonal(
    //               onPressed: isAdLoaded
    //                   ? () async => purhasesNotifier.watchAd(context)
    //                   : null,
    //               child: isAdLoaded
    //                   ? Text(l10n.watchAd)
    //                   : const UiCircularProgress(),
    //             )
    //           else
    //             const Text('Rewards ended. But, please come back tomorrow:)'),
    //         ]
    //       : [],
    // );
  }
}
