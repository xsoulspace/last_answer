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
    return Column(
      children: [
        if (purchasesNotifier.value.isLoading) const UiCircularProgress(),
        Text(
          // ignore: lines_longer_than_80_chars
          'You have supported the app for ${state.supporterDaysCount} days! \n🎉🎉🎉 Thank you for your support! 🎉🎉🎉',
        ),
        Text(
          'Supporter days left:  ${state.daysOfSupporterLeft}',
        ),
        const Text('Become pro to get unlimited access to all features!'),
        const Gap(24),
        ...children,
      ],
    );
  }
}
