
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_paywall/paywall_flow.dart';
import 'package:oka_store/oka_store.dart';
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
  Widget build(final BuildContext context) => LaScaffold(
    topBar: LaTopBar(
      leading: LaButton.icon(
        icon: const Icon(Icons.arrow_back, size: 18),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleText: 'Last Answer Pro',
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(16),
          Text(
            'Agents, sync, and connected workflows',
            textAlign: TextAlign.center,
            style: context.laUi.section,
          ),
          const Gap(8),
          Text(
            'The core app works offline for free. Pro unlocks agents, '
            'intentcall actions, ACP support and cross-app sync.',
            textAlign: TextAlign.center,
            style: context.laUi.body,
          ),
          const Gap(24),
          const _SubscriptionPlans(),
          const Gap(16),
          const _SubscriptionActions(),
          const Gap(16),
        ],
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

    // ADR 0037 — the kernel's binding names the store openly; the
    // RuStore login wall applies only in a RuStore kernel.
    final storeKey = context.watch<MonetizationStoreBinding>().key;
    if (storeKey == storeKeyRuStore &&
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
          child: LaSpinner(size: 24),
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
          duration: context.laUi.motionSettle,
          curve: context.laUi.motionCurve,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? context.laUi.accent : context.laUi.rule,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? context.laUi.selectedFill() : null,
          ),
          child: Row(
            children: [
              LaRadio<PurchaseProductId>(
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
                          child: Text(label, style: context.laUi.emphasis),
                        ),
                        if (isBestValue)
                          LaPill(
                            label: 'BEST VALUE',
                            background: context.laUi.accent,
                            color: context.laUi.onAccent,
                            radius: BorderRadius.circular(12),
                          ),
                      ],
                    ),
                    if (product.formattedPrice.isNotEmpty)
                      Text(
                        product.formattedPrice,
                        style: context.laUi.body.copyWith(
                          fontSize: 16,
                          color: context.laUi.accent,
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
            Icon(Icons.autorenew, size: 18, color: context.laUi.inkMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Recurring billing, cancel anytime.',
                style: context.laUi.compact,
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
        Icon(icon, size: 48, color: context.laUi.danger),
        const Gap(12),
        Text(message, textAlign: TextAlign.center),
        if (actionLabel != null && onAction != null) ...[
          const Gap(16),
          LaButton(
            variant: LaButtonVariant.outline,
            onPressed: onAction,
            label: actionLabel,
          ),
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
              style: context.laUi.compact.copyWith(
                color: context.laUi.danger,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        LaButton(
          variant: LaButtonVariant.primary,
          expand: true,
          onPressed: selected.isLoaded && !isBusy
              ? () => unawaited(_subscribe(context))
              : null,
          label: subscriptionStatus.isRestoring ? 'Restoring…' : 'SUBSCRIBE',
        ),
        const Gap(8),
        LaButton(
          variant: LaButtonVariant.outline,
          expand: true,
          onPressed: isBusy
              ? null
              : () =>
                    unawaited(context.read<MonetizationFoundation>().restore()),
          label: 'Restore Purchases',
        ),
        const Gap(8),
        LaButton(
          variant: LaButtonVariant.ghost,
          expand: true,
          onPressed: () => PaywallFlow.passPaywall(context),
          label: 'Continue Free',
        ),
      ],
    );
  }
}
