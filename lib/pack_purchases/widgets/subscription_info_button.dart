part of pack_purchases;

class SubscriptionInfoButton extends StatelessWidget {
  const SubscriptionInfoButton({
    required this.paymentsController,
    super.key,
  });

  final PaymentsController paymentsController;

  void openSubscriptionPopup({required final BuildContext context}) {}

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            TextButton(
              onPressed: () => openSubscriptionPopup(context: context),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: paymentsController.isPatronSubscription
                          ? S.current.patronSubscription
                          : S.current.freeSubscription,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
