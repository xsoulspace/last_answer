import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/views/supporter_view/supporter_base_view.dart';

class SupportAppView extends StatelessWidget {
  const SupportAppView({super.key});

  @override
  Widget build(final BuildContext context) {
    final purhasesNotifier = context.watch<PurchasesNotifier>();
    final purchasesAdsService = context.watch<PurchasesAdsService>();
    final isAdLoaded = purchasesAdsService.isLoaded;
    return SupportAppBaseView(
      children: purhasesNotifier.isAdSupported
          ? [
              const Text(
                // ignore: lines_longer_than_80_chars
                'Please note: Ad curently works only in Google Chrome and Firefox. Safari is blocking the ad, so currently it is not working.',
              ),
              FilledButton.tonal(
                onPressed: isAdLoaded
                    ? () async => purhasesNotifier.watchAd(context)
                    : null,
                child: isAdLoaded
                    ? const Text('Watch ad')
                    : const UiCircularProgress(),
              ),
            ]
          : [],
    );
  }
}
