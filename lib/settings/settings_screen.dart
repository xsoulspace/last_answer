import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/entitlement/pro_entitlement.dart';
import 'package:lastanswer/other/feedback.dart';
import 'package:lastanswer/settings/views/views.dart';

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
    void onBack() => onClose != null ? onClose!() : Navigator.pop(context);
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
    Widget child = TabBarView(
      physics: const SpeedyPageViewScrollPhysics(),
      children: tabsViews,
    );
    final appbar = AppBar(
      centerTitle: true,
      leading: CupertinoCloseButton(onPressed: onBack),
      actions: const [FeedbackButton()],
      title: Text(context.l10n.settings),
      bottom: TabBar(
        tabs: [
          Tab(text: context.l10n.generalSettingsShortTitle),
          Tab(text: context.l10n.agentSettingsTitle),
          if (isAccountViewVisible) Tab(text: context.l10n.myAccount),
        ],
      ),
    );

    if (embedded) {
      child = Column(
        children: [
          SizedBox(width: double.infinity, height: 80, child: appbar),
          Expanded(child: child),
        ],
      );
    } else if (screenLayout.small) {
      child = Scaffold(
        appBar: appbar,
        backgroundColor: context.theme.canvasColor,
        body: child,
      );
    } else {
      child = Scaffold(
        backgroundColor: context.theme.canvasColor,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: ScreenLayout.maxSmallWidth,
              maxWidth: ScreenLayout.maxSmallWidth + 150,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: ScreenLayout.maxSmallWidth,
                  height: 80,
                  child: appbar,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      );
    }
    return DefaultTabController(length: tabsViews.length, child: child);
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
