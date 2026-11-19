import 'package:flutter/gestures.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportAppBaseView extends StatelessWidget {
  const SupportAppBaseView({required this.children, super.key});
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
        if (purchasesNotifier.value.isLoading) const LaSpinner(),
        _FadeIn(
          child: Text(
            // ignore: lines_longer_than_80_chars
            '${l10n.youUsedThisAppFor} ${state.usedDaysCount} ${l10n.days}${supporterDaysCount > 0 ? ' ${l10n.andHaveSupported} $supporterDaysCount ${l10n.days}!' : ''}',
          ),
        ),
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
        const LaHairline(),
        const Gap(18),
        Text(l10n.whatSupporterDaysMeans, style: context.laUi.emphasis),
        const Gap(18),
        _FadeIn(child: Text(l10n.supporterDaysAre)),
        const Gap(24),
        _FadeIn(child: Text(l10n.supporterDaysMainFunctionality)),
        const Gap(24),
        _FadeIn(child: Text(l10n.toGetSupporterDays)),
        const Gap(48),
      ],
    );
  }
}

/// Kit-motion fade-in replacing the old `flutter_animate` `.fadeIn()` chain
/// (DESIGN.md v6 motion tokens: motionSettle + motionCurve).
class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child});
  final Widget child;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    if (mounted) setState(() => _visible = true);
  }

  @override
  Widget build(final BuildContext context) => AnimatedOpacity(
    opacity: _visible ? 1 : 0,
    duration: context.laUi.motionSettle,
    curve: context.laUi.motionCurve,
    child: widget.child,
  );
}
