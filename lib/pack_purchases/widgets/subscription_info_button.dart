import 'package:flutter/material.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/pack_purchases_i/pack_purchases_i.dart';

class SubscriptionInfoButton extends StatelessWidget {
  const SubscriptionInfoButton({
    required final this.paymentsController,
    final Key? key,
  }) : super(key: key);

  final PaymentsControllerI paymentsController;

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
}
