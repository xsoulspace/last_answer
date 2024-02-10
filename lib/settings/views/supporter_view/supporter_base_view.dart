import 'package:lastanswer/common_imports.dart';

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
    String text = 'You are supporting the app for $supporterDaysCount days!';
    if (supporterDaysCount > 0) {
      text += '\n 🎉🎉🎉 Thank you for your support! 🎉🎉🎉';
    }
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
        Text(text),
        const Gap(24),
        Text(supporterDaysText),
        const Gap(24),
        ...children,
      ],
    );
  }
}
