import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/other/other.dart';
import 'package:lastanswer/settings/features_widgets/general_settings_view.dart';

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
          ChangelogView(),
        ],
      ),
    );
    final appbar = AppBar(
      centerTitle: true,
      leading: CupertinoCloseButton(onPressed: onBack),
      title: Text(context.l10n.settings),
      bottom: TabBar(
        tabs: [
          Tab(text: context.l10n.generalSettingsShortTitle),
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
    return DefaultTabController(length: 2, child: child);
  }
}

class ChangelogView extends StatelessWidget {
  const ChangelogView({super.key});

  @override
  Widget build(final BuildContext context) {
    final notificationController = context.read<NotificationsNotifier>();
    final updates = notificationController.updates;
    return ListView.builder(
      itemCount: updates.length,
      padding: const EdgeInsets.all(24),
      itemBuilder: (final context, final i) {
        final notification = updates[i];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 32, bottom: 24),
              child: ChangelogTile(notification: notification),
            ),
            Text(notification.message.localize(context)),
          ],
        );
      },
    );
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
