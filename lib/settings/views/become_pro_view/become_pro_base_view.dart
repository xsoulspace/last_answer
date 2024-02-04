import 'package:lastanswer/common_imports.dart';

class BecomeProBaseView extends StatelessWidget {
  const BecomeProBaseView({
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
        if (state.isActive)
          Text(
            'You have ${state.purchasedDaysLeft} days.',
          )
        else
          const Text('Become pro to get unlimited access to all features!'),
        const Gap(24),
        ...children,
      ],
    );
  }
}
