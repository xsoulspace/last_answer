import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/other/feedback.dart';
import 'package:lastanswer/settings/views/views.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    void onBack() => Navigator.pop(context);
    final screenLayout = ScreenLayout.of(context);
    Widget child = const SelectionArea(
      child: TabBarView(
        physics: SpeedyPageViewScrollPhysics(),
        children: [
          GeneralSettingsView(),
          MyAccountView(),
          ChangelogView(),
        ],
      ),
    );
    final appbar = AppBar(
      centerTitle: true,
      leading: CupertinoCloseButton(onPressed: onBack),
      actions: const [FeedbackButton()],
      title: Text(context.l10n.settings),
      bottom: TabBar(
        tabs: [
          Tab(text: context.l10n.generalSettingsShortTitle),
          Tab(text: context.l10n.myAccount),
          Tab(text: context.l10n.changeLog),
        ],
      ),
    );

    if (screenLayout.small) {
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
    return DefaultTabController(length: 3, child: child);
  }
}

class SpeedyPageViewScrollPhysics extends ScrollPhysics {
  const SpeedyPageViewScrollPhysics({super.parent});

  @override
  SpeedyPageViewScrollPhysics applyTo(final ScrollPhysics? ancestor) =>
      SpeedyPageViewScrollPhysics(parent: buildParent(ancestor));

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}