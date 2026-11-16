import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/entitlement/pro_entitlement.dart';
import 'package:lastanswer/other/feedback.dart';
import 'package:lastanswer/settings/views/views.dart';
import 'package:lastanswer/widgets/legacy_kit/legacy_kit.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({this.onClose, this.embedded = false, super.key});

  /// Phase 1e — the embedding seam (settings-as-view): hosted in a
  /// shell view tab, the close affordance calls THIS instead of
  /// popping the enclosing route (a pop from inside a view would take
  /// the whole shell down). Null keeps the route behaviour.
  final VoidCallback? onClose;

  /// Hosted inside a shell view: no Scaffold of its own — the tab is
  /// the frame (the shell grammar has no exceptions, redesign §2.2.5).
  final bool embedded;

  @override
  Widget build(final BuildContext context) {
    final onBack = onClose ?? () => Navigator.pop(context);
    final screenLayout = ScreenLayout.of(context);
    // Plan v5 4a — the Pro entry, un-hidden: the Account/Pro tab shows
    // when this build's store target declares products OR the
    // entitlement dev-override is on. A missing purchase provider
    // degrades honestly downstream (the paywall names the store's
    // absence), never by dead-gating the entry.
    final isAccountViewVisible =
        context.read<PurchasesNotifier>().isProEntryVisible ||
        context.watch<ProEntitlement?>()?.devOverride == true;
    final appFeaturesNotifier = context.watch<AppFeaturesNotifier>();
    final tabsViews = [
      const GeneralSettingsView(),
      const AgentSettingsView(),
      if (isAccountViewVisible)
        if (appFeaturesNotifier.value.isRemoteServicesEnabled)
          const MyAccountViewRemoteImpl()
        else
          const MyAccountViewLocalImpl(),
    ];
    final labels = [
      context.l10n.generalSettingsShortTitle,
      context.l10n.agentSettingsTitle,
      if (isAccountViewVisible) context.l10n.myAccount,
    ];
    final pageController = usePageController();
    final currentTab = useState(0);
    final theme = context.laUi;

    final pager = PageView(
      controller: pageController,
      physics: const SpeedyPageViewScrollPhysics(),
      onPageChanged: (final index) => currentTab.value = index,
      children: tabsViews,
    );

    // The kit tab strip (Material AppBar+TabBar grammar retired): quiet
    // labels over the top bar, the ONE accent underline on the selected
    // tab — the shell's own tab law, at phone scale.
    final topBar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LaTopBar(
          leading: LaButton.icon(
            key: const ValueKey('settings.close'),
            icon: const Icon(Icons.close, size: 20),
            onPressed: onBack,
          ),
          title: Text(
            context.l10n.settings,
            textAlign: TextAlign.center,
            style: theme.emphasis,
          ),
          trailing: const FeedbackButton(),
        ),
        LaTabStrip(
          labels: labels,
          currentIndex: currentTab.value,
          onTap: (final index) => pageController.animateToPage(
            index,
            duration: theme.motionSettle,
            curve: theme.motionCurve,
          ),
        ),
      ],
    );

    Widget child;
    if (embedded) {
      child = Column(
        children: [
          topBar,
          Expanded(child: pager),
        ],
      );
    } else if (screenLayout.small) {
      child = LaScaffold(topBar: topBar, body: pager);
    } else {
      child = LaScaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: ScreenLayout.maxSmallWidth,
              maxWidth: ScreenLayout.maxSmallWidth + 150,
            ),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ScreenLayout.maxSmallWidth,
                  ),
                  child: topBar,
                ),
                Expanded(child: pager),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}

class SpeedyPageViewScrollPhysics extends ScrollPhysics {
  const SpeedyPageViewScrollPhysics({super.parent});

  @override
  SpeedyPageViewScrollPhysics applyTo(final ScrollPhysics? ancestor) =>
      SpeedyPageViewScrollPhysics(parent: buildParent(ancestor));

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 80, stiffness: 100, damping: 1);
}
