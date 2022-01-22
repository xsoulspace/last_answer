part of pack_purchases;

class SubscriptionInfoButton extends StatelessWidget {
  const SubscriptionInfoButton({
    required final this.paymentsController,
    final Key? key,
  }) : super(key: key);

  final PaymentsController paymentsController;

  void openSubscriptionPopup({required final BuildContext context}) {}

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          TextButton(
            onPressed: () => openSubscriptionPopup(context: context),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: paymentsController.isProSubscription
                        ? S.current.proSubscription
                        : S.current.freeSubscription,
                  ),
                  TextSpan(
                    text: S.current.learnMore,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
