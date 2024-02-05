import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lastanswer/common_imports.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    final purchasesNotifier = context.watch<PurchasesNotifier>();
    final purchasesContainer = purchasesNotifier.value;

    if (PlatformInfo.isNativeMobile) {
      // final nativeIASubscriptions =
      //     purchasesContainer.value.nativeIASubscriptions;
      //   return ListView(
      //     primary: false,
      //     children: [
      //       const Gap(24),
      //       if (nativeIASubscriptions.isEmpty)
      //         const Text('No plans available.')
      //       else
      //         ...nativeIASubscriptions.map(
      //           (final e) => LoadableWidget(
      //             builder: (final context, final setLoading, final isLoading) =>
      //                 PurchasableProductTile(
      //               details: e,
      //               activeProductId: IAPId.proOneTimePurchase,
      //               //  purchasesContainer
      //               //     .value.purchases.activePurchase.productId,
      //               isLoading: isLoading,
      //               onPressed: () async {
      //                 setLoading(true);
      //                 // await userNotifier.buySubscription(e);
      //                 setLoading(false);
      //               },
      //             ),
      //           ),
      //         ),
      //     ],
      //   );
      // } else {
      //   return const Text('No plans available.');
    }
    return const SizedBox();
  }
}

class PurchasableProductTile extends StatelessWidget {
  const PurchasableProductTile({
    required this.details,
    required this.onPressed,
    required this.activeProductId,
    required this.isLoading,
    super.key,
  });
  final bool isLoading;
  final VoidCallback onPressed;
  final ProductDetails details;
  final IAPId activeProductId;
  @override
  Widget build(final BuildContext context) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(details.title),
            Text(details.description),
            Text(details.price),
            if (activeProductId.id == details.id)
              const Text('Active')
            else
              TextButton(onPressed: onPressed, child: const Text('Purchase')),
          ],
        ),
      );
}

class PaymentsHistoryListView extends StatelessWidget {
  const PaymentsHistoryListView({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    return ListView(
      primary: false,
      children: const [
        Gap(24),
        Text('No payment history'),
        Gap(24),
      ],
    );
  }
}
