import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:lastanswer/ui_pay/paywall_flow.dart';
import 'package:provider/provider.dart';
import 'package:xsoulspace_installation_store/xsoulspace_installation_store.dart';
import 'package:xsoulspace_monetization_foundation/xsoulspace_monetization_foundation.dart';
import 'package:xsoulspace_monetization_interface/xsoulspace_monetization_interface.dart';

/// {@template paywall_screen}
/// Paywall screen displaying subscription plans for Last Answer Pro.
/// {@endtemplate}
class PaywallScreen extends StatefulWidget {
  /// {@macro paywall_screen}
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      unawaited(
        context.read<MonetizationFoundation>().checkActiveSubscription(),
      );
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Last Answer Pro')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(16),
            Text(
              'Agents, sync, and connected workflows',
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'The core app works offline for free. Pro unlocks agents, '
              'intentcall actions, ACP support and cross-app sync.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const Gap(24),
            const _SubscriptionPlans(),
            const Gap(16),
            const _SubscriptionActions(),
            const Gap(16),
          ],
        ),
      ),
    ),
  );
}

class _SubscriptionPlans extends StatefulWidget {
  const _SubscriptionPlans();

  @override
  State<_SubscriptionPlans> createState() => _SubscriptionPlansState();
}

class _SubscriptionPlansState extends State<_SubscriptionPlans> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      final status = context.read<MonetizationStoreStatusResource>().status;
      if (status == MonetizationStoreStatus.loaded) {
        unawaited(
          context.read<MonetizationFoundation>().loadSubscriptions(
            productIds: MonetizationProducts.subscriptionsForBuild,
          ),
        );
      }
    });
  }

  void _selectPlan(final PurchaseProductId id) {
    final details = context
        .read<AvailableSubscriptionsResource>()
        .getSubscription(id);
    if (details == null) return;
    context.read<PaywallSelectedSubscriptionResource>().setSelectedProductId(
      selectedProductId: id,
      selectedProductDetails: details,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final monetizationStatus = context
        .watch<MonetizationStoreStatusResource>()
        .status;
    final selected = context.watch<PaywallSelectedSubscriptionResource>();
    final subscriptions = context
        .watch<AvailableSubscriptionsResource>()
        .subscriptions;

    if (monetizationStoreTarget == InstallationTargetStore.rustore &&
        monetizationStatus == MonetizationStoreStatus.userNotAuthorized) {
      return _MessageCard(
        icon: Icons.account_circle_outlined,
        message: 'Please log in to RuStore to continue',
        actionLabel: 'Retry',
        onAction: () => unawaited(
          context.read<MonetizationFoundation>().loadSubscriptions(
            productIds: MonetizationProducts.subscriptionsForBuild,
          ),
        ),
      );
    }
    if (monetizationStatus == MonetizationStoreStatus.notAvailable) {
      return const _MessageCard(
        icon: Icons.error_outline,
        message: 'Subscriptions are not available on this device.',
      );
    }
    if (monetizationStatus == MonetizationStoreStatus.loading ||
        subscriptions.isLoading ||
        selected.selectedProductDetails == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (subscriptions.value.isEmpty) {
      return _MessageCard(
        icon: Icons.error_outline,
        message: 'No subscriptions found',
        actionLabel: 'Retry',
        onAction: () => unawaited(
          context.read<MonetizationFoundation>().loadSubscriptions(
            productIds: MonetizationProducts.subscriptionsForBuild,
          ),
        ),
      );
    }

    Widget planCard({
      required final MonetizationProducts preset,
      required final String label,
      required final bool isBestValue,
    }) {
      final product = subscriptions.value.firstWhere(
        (final e) => e.productId == preset.productId,
        orElse: () => PurchaseProductDetailsModel.empty,
      );
      final isSelected = selected.selectedProductId == preset.productId;
      return GestureDetector(
        onTap: () => _selectPlan(preset.productId),
        child: AnimatedContainer(
          duration: 300.milliseconds,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? context.colorScheme.primaryContainer.withValues(alpha: 0.1)
                : null,
          ),
          child: Row(
            children: [
              Radio<PurchaseProductId>(
                value: preset.productId,
                groupValue: selected.selectedProductId,
                onChanged: (final value) {
                  if (value != null) _selectPlan(value);
                },
              ),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isBestValue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'BEST VALUE',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (product.formattedPrice.isNotEmpty)
                      Text(
                        product.formattedPrice,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        planCard(
          preset: MonetizationProducts.sMonth1,
          label: 'Monthly',
          isBestValue: false,
        ),
        const Gap(8),
        planCard(
          preset: MonetizationProducts.sMonth3,
          label: '3 Months',
          isBestValue: false,
        ),
        const Gap(8),
        planCard(
          preset: MonetizationProducts.sYear,
          label: 'Yearly',
          isBestValue: true,
        ),
        const Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.autorenew,
              size: 18,
              color: context.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Recurring billing, cancel anytime.',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Icon(icon, size: 48, color: context.colorScheme.error),
        const Gap(12),
        Text(message, textAlign: TextAlign.center),
        if (actionLabel != null && onAction != null) ...[
          const Gap(16),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

class _SubscriptionActions extends StatefulWidget {
  const _SubscriptionActions();

  @override
  State<_SubscriptionActions> createState() => _SubscriptionActionsState();
}

class _SubscriptionActionsState extends State<_SubscriptionActions> {
  VoidCallback? _disposeListener;

  @override
  void initState() {
    super.initState();
    _disposeListener = PaywallFlow.listenResolvePendingThenRecheck(
      context: context,
    );
  }

  @override
  void dispose() {
    _disposeListener?.call();
    super.dispose();
  }

  Future<void> _subscribe(final BuildContext context) async {
    final details = context
        .read<PaywallSelectedSubscriptionResource>()
        .selectedProductDetails;
    if (details == null) return;
    await context.read<MonetizationFoundation>().subscribe(details);
    if (!context.mounted) return;
    unawaited(PaywallFlow.checkSubscriptionStatus(context));
  }

  @override
  Widget build(final BuildContext context) {
    final selected = context.watch<PaywallSelectedSubscriptionResource>();
    final subscriptionStatus = context.watch<SubscriptionStatusResource>();
    final paywallError = context.watch<PurchasePaywallErrorResource>();
    final isBusy =
        subscriptionStatus.isPurchasing || subscriptionStatus.isRestoring;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (paywallError.hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              paywallError.error,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        FilledButton(
          onPressed: selected.isLoaded && !isBusy
              ? () => unawaited(_subscribe(context))
              : null,
          child: Text(
            subscriptionStatus.isRestoring ? 'Restoring…' : 'SUBSCRIBE',
          ),
        ),
        const Gap(8),
        OutlinedButton(
          onPressed: isBusy
              ? null
              : () =>
                    unawaited(context.read<MonetizationFoundation>().restore()),
          child: const Text('Restore Purchases'),
        ),
        const Gap(8),
        TextButton(
          onPressed: () => PaywallFlow.passPaywall(context),
          child: const Text('Continue Free'),
        ),
      ],
    );
  }
}
