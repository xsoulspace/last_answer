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
    final l10n = context.l10n;
    final supporterDaysCount = state.supporterDaysCount;
    final String supporterDaysText;
    if (state.daysOfSupporterLeft > 0) {
      supporterDaysText =
          '${l10n.supporterDaysLeft}:  ${state.daysOfSupporterLeft}';
    } else {
      supporterDaysText = l10n.youCanSupportAppDevelopment;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (purchasesNotifier.value.isLoading) const UiCircularProgress(),
        Text(
          // ignore: lines_longer_than_80_chars
          '${l10n.youUsedThisAppFor} ${state.usedDaysCount} ${l10n.days}${supporterDaysCount > 0 ? ' ${l10n.andHaveSupported} $supporterDaysCount ${l10n.days}!' : ''}',
        ).animate().fadeIn(),
        const Gap(24),
        Text(supporterDaysText),
        const Gap(24),
        ...children.isEmpty
            ? [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n
                            .unfortunatelyThisPlatformHasNoAbilitiesToSupport,
                      ),
                      TextSpan(text: l10n.butYouCanGoTo),
                      TextSpan(
                        text: l10n.toTheWebsite,
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
        const Gap(18),
        Text(
          l10n.whatSupporterDaysMeans,
          style: context.textTheme.titleSmall,
        ),
        const Gap(18),
        Text(l10n.supporterDaysAre).animate().fadeIn(),
        const Gap(24),
        Text(l10n.supporterDaysMainFunctionality).animate().fadeIn(),
        const Gap(24),
        Text(l10n.toGetSupporterDays).animate().fadeIn(),
        const Gap(48),
      ],
    );
  }
}
