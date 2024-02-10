import 'package:flutter/widgets.dart';
import 'package:lastanswer/settings/views/supporter_view/supporter_base_view.dart';

class SupportAppView extends StatelessWidget {
  const SupportAppView({super.key});

  @override
  Widget build(final BuildContext context) => const SupportAppBaseView(
        children: [
          Text(
            'Unfortunately this platform is not supporting Pro upgrade. Please use website to upgrade.',
          ),
        ],
      );
}
