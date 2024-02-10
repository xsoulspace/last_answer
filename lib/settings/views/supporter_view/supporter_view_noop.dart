import 'package:flutter/widgets.dart';
import 'package:lastanswer/settings/views/supporter_view/supporter_base_view.dart';

class SupportAppView extends StatelessWidget {
  const SupportAppView({super.key});

  @override
  Widget build(final BuildContext context) => const SupportAppBaseView(
        children: [
          Text(
            // ignore: lines_longer_than_80_chars
            'Unfortunately this platform has no abilities to support the app:). But you can go to the website:)',
          ),
        ],
      );
}
