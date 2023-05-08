import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:lastanswer/pack_app/screens/home_mouse/widgets/widgets.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';
import 'package:ui_kit/ui_kit.dart';

part 'home_mouse_tablet_state.dart';

class HomeMouseTabletScreen extends HookWidget {
  const HomeMouseTabletScreen({required this.contentBuilder, super.key});
  final WidgetBuilder contentBuilder;
  static const double appBarHeight = 56;
  @override
  Widget build(final BuildContext context) {
    final state = _useScreenState(read: context.read);
    final theme = Theme.of(context);
    final uiTheme = UiTheme.of(context);
    final heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      // TODO(arenukvern):
      /// Currently the system theme is not defining correctly if user
      /// OS has an auto theme. Need to investigate the reason via
      /// OS native code and if the problem will be fixed, consider
      /// to uncomment the following line.
      // backgroundColor: Colors.transparent,
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            width: state.leftWidth,
            left: 0,
            bottom: 0,
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.shadow,
                  ),
                ),
              ),
              child: Column(
                children: [
                  MacosBackgroundAppBar(
                    height: appBarHeight,
                    onShowInfo: state.onShowInfo,
                    onShowSettings: state.onShowSettings,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Expanded(child: ProjectsList()),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: const HomeVerticalMenu(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 200),
                width: state.leftPaneOpen ? state.leftWidth : 0,
              ),
              Expanded(
                child: AnimatedContainer(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 200),
                  color: theme.scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      const SizedBox(height: appBarHeight),
                      Expanded(child: contentBuilder(context)),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (final context) {
                  if (uiTheme.persistentFormFactors.width ==
                      WidthFormFactor.desktop) {
                    final size = MediaQuery.of(context).size;
                    final rightColumnWidth =
                        (size.width / 4).clamp(280, 400).toDouble();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: rightColumnWidth,
                      height: double.infinity,
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
          Positioned(
            width: state.leftWidth,
            child: MacosForegroundAppBar(
              leftPaneOpen: state.leftPaneOpen,
              height: appBarHeight,
              onSwitchLeftPane: state.onSwitchLeftPane,
            ),
          ),
        ],
      ),
    );
  }
}

class MacosForegroundAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MacosForegroundAppBar({
    required this.onSwitchLeftPane,
    required this.height,
    required this.leftPaneOpen,
    super.key,
  });
  final double height;
  @override
  Size get preferredSize => Size.fromHeight(height);
  final VoidCallback onSwitchLeftPane;
  final bool leftPaneOpen;
  @override
  Widget build(final BuildContext context) {
    final uiTheme = UiTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: preferredSize.height),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: uiTheme.spacing.medium,
          vertical: 1,
        ),
        child: Row(
          children: [
            const SizedBox(width: 50),
            CupertinoActionIconButton(
              onPressed: onSwitchLeftPane,
              icon: CupertinoIcons.sidebar_left,
            ),
          ],
        ),
      ),
    );
  }
}

class MacosBackgroundAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MacosBackgroundAppBar({
    required this.height,
    required this.onShowInfo,
    required this.onShowSettings,
    super.key,
  });
  final double height;
  @override
  Size get preferredSize => Size.fromHeight(height);
  final VoidCallback onShowInfo;
  final VoidCallback onShowSettings;
  @override
  Widget build(final BuildContext context) {
    final uiTheme = UiTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: preferredSize.height),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: uiTheme.spacing.medium,
          vertical: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoActionIconButton(
              onPressed: onShowInfo,
              icon: CupertinoIcons.info,
            ),
            CupertinoActionIconButton(
              onPressed: onShowSettings,
              icon: CupertinoIcons.gear,
            ),
          ],
        ),
      ),
    );
  }
}
