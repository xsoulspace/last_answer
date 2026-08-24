import 'package:intl/intl.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_pay/paywall_flow.dart';
import 'package:lastanswer/ui_pay/ui_pay.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';

/// "Become Pro" tab: shows subscription status and entry to the paywall.
class SupportAppView extends StatelessWidget {
  const SupportAppView({super.key});

  @override
  Widget build(final BuildContext context) {
    final activeSubscription = context
        .watch<ActiveSubscriptionResource>()
        .subscription;
    final isSubscribed = context
        .watch<SubscriptionStatusResource>()
        .isSubscribed;

    if (isSubscribed && activeSubscription.purchaseId.isNotEmpty) {
      return const _SubscribedCard();
    }
    return const _PaywallEntry();
  }
}

class _SubscribedCard extends StatelessWidget {
  const _SubscribedCard();

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Gap(24),
      Icon(
        Icons.workspace_premium,
        size: 56,
        color: context.colorScheme.primary,
      ),
      const Gap(16),
      Text(
        'Thank you for supporting Last Answer!',
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(),
      const Gap(24),
      ListenableBuilder(
        listenable: context.read<ActiveSubscriptionResource>(),
        builder: (final context, final _) {
          final subscription = context
              .watch<ActiveSubscriptionResource>()
              .subscription;
          final expiry = subscription.expiryDate;
          return Text(
            expiry == null
                ? 'Your subscription is active.'
                // ignore: lines_longer_than_80_chars
                : 'Your subscription is active until ${DateFormat.yMMMd().format(expiry)}.',
            textAlign: TextAlign.center,
          );
        },
      ),
      const Gap(24),
      OutlinedButton(
        onPressed: () async =>
            context.read<MonetizationFoundation>().openSubscriptionManagement(),
        child: const Text('Manage Subscription'),
      ),
    ],
  );
}

class _PaywallEntry extends StatelessWidget {
  const _PaywallEntry();

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Gap(24),
      Icon(Icons.auto_awesome, size: 56, color: context.colorScheme.primary),
      const Gap(16),
      Text(
        'Unlock Last Answer Pro',
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(),
      const Gap(8),
      const Text(
        'Agents, intentcall, ACP support, sync with Daily Budget Planner '
        'and more. The core app works offline for free — Pro unlocks the '
        'connected experience.',
        textAlign: TextAlign.center,
      ).animate().fadeIn(delay: 100.ms),
      const Gap(24),
      FilledButton(
        onPressed: () => PaywallFlow.pushPaywall(context),
        child: const Text('See Plans'),
      ),
      const Gap(8),
      TextButton(
        onPressed: () async =>
            context.read<MonetizationFoundation>().checkActiveSubscription(),
        child: const Text('Restore Purchases'),
      ),
    ],
  );
}
