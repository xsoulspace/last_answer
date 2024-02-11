import 'package:flutter/gestures.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportAppBaseView extends StatelessWidget {
  const SupportAppBaseView({
    required this.children,
    super.key,
  });
  final List<Widget> children;
  @override
  Widget build(final BuildContext context) {
    final purchasesNotifier = context.watch<PurchasesNotifier>();
    final state = purchasesNotifier.value.value;
    final supporterDaysCount = state.supporterDaysCount;
    final String supporterDaysText;
    if (state.daysOfSupporterLeft > 0) {
      supporterDaysText = 'Supporter days left:  ${state.daysOfSupporterLeft}';
    } else {
      supporterDaysText =
          // ignore: lines_longer_than_80_chars
          'You can start supporting the app development by watching short ad below. This will help me to improve the app and make it better.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (purchasesNotifier.value.isLoading) const UiCircularProgress(),
        Text(
          // ignore: lines_longer_than_80_chars
          'You used this app for ${state.usedDaysCount} days${supporterDaysCount > 0 ? ' and have supported $supporterDaysCount days!' : ''}',
        ),
        const Gap(24),
        Text(supporterDaysText),
        const Gap(24),
        ...children.isEmpty
            ? [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            // ignore: lines_longer_than_80_chars
                            'Unfortunately this platform has no abilities to support the app, yet:)',
                      ),
                      const TextSpan(text: 'But you can go'),
                      TextSpan(
                        text: 'to the website:)',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await launchUrlString(
                              'https://xsoulspace.dev/last_answer',
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ]
            : children,
        const Divider(),
        const Gap(48),
        const Text(
          // ignore: lines_longer_than_80_chars
          'Supporter Days are the days given to the user of the application for supporting the project. Every time the user uses the application, one Supporter Day is deducted (only once per day, regardless of how many times the user opens the application in a day) and added to Supported Days (the total number of days the person has supported the project). If the user has never opened the application, the days are not deducted :)',
        ),
        const Gap(24),
        const Text(
          // ignore: lines_longer_than_80_chars
          'The main functionality of Supporter Days does not affect anything, but in the future, they will provide the opportunity to use additional features of the application - so for me, the most important thing is that under no circumstances will the main functionality of adding/editing notes and ideas be blocked, and everything else is just bonuses if a person decides to support the project :)',
        ),
        const Gap(24),
        const Text(
          // ignore: lines_longer_than_80_chars
          'To get Supporter Days, the user can press the "watch ad" button and after watching the advertisement (I will experiment, but for now it\'s 60 seconds), they will be given 7 Supporter Days.',
        ),
        const Gap(48),
      ],
    );
  }
}
