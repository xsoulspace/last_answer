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
      Icon(Icons.workspace_premium, size: 56, color: context.laUi.accent),
      const Gap(16),
      _FadeIn(
        child: Text(
          'Thank you for supporting Last Answer!',
          style: context.laUi.section,
          textAlign: TextAlign.center,
        ),
      ),
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
      LaButton(
        variant: LaButtonVariant.outline,
        expand: true,
        onPressed: () =>
            context.read<MonetizationFoundation>().openSubscriptionManagement(),
        label: 'Manage Subscription',
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
      Icon(Icons.auto_awesome, size: 56, color: context.laUi.accent),
      const Gap(16),
      _FadeIn(
        child: Text(
          'Unlock Last Answer Pro',
          style: context.laUi.section,
          textAlign: TextAlign.center,
        ),
      ),
      const Gap(8),
      const _FadeIn(
        delay: Duration(milliseconds: 100),
        child: Text(
          'Agents, intentcall, ACP support, sync with Daily Budget Planner '
          'and more. The core app works offline for free — Pro unlocks the '
          'connected experience.',
          textAlign: TextAlign.center,
        ),
      ),
      const Gap(24),
      LaButton(
        variant: LaButtonVariant.primary,
        expand: true,
        onPressed: () => PaywallFlow.pushPaywall(context),
        label: 'See Plans',
      ),
      const Gap(8),
      LaButton(
        variant: LaButtonVariant.ghost,
        expand: true,
        onPressed: () =>
            context.read<MonetizationFoundation>().checkActiveSubscription(),
        label: 'Restore Purchases',
      ),
    ],
  );
}

/// Kit-motion fade-in replacing the old `flutter_animate` `.fadeIn()` chain
/// (DESIGN.md v6 motion tokens: motionSettle + motionCurve).
class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay > Duration.zero) {
      // A cancellable timer, not an awaited Future.delayed: a section
      // disposed mid-fade (the settings filter) must not leave a
      // pending timer behind.
      _timer = Timer(widget.delay, _reveal);
    } else {
      _visible = true;
    }
  }

  void _reveal() {
    if (mounted) setState(() => _visible = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedOpacity(
    opacity: _visible ? 1 : 0,
    duration: context.laUi.motionSettle,
    curve: context.laUi.motionCurve,
    child: widget.child,
  );
}
