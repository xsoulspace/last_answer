import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/views/supporter_view/supporter_base_view.dart';

class SupportAppView extends StatelessWidget {
  const SupportAppView({super.key});

  @override
  Widget build(final BuildContext context) {
    final purhasesNotifier = context.watch<PurchasesNotifier>();
    return SupportAppBaseView(
      children: purhasesNotifier.isAdSupported
          ? [
              TextButton(
                onPressed: () async => purhasesNotifier.watchAd(context),
                child: const Text('Watch ad'),
              ),
            ]
          : [],
    );
  }
}
