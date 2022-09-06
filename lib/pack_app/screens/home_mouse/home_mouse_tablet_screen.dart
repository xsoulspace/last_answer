import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_design_core/la_design_core.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/app_router_controller.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';

part 'home_mouse_tablet_state.dart';

class HomeMouseTabletScreen extends HookWidget {
  const HomeMouseTabletScreen({required this.contentBuilder, super.key});
  final WidgetBuilder contentBuilder;
  static const double appBarHeight = 56.0;
  @override
  Widget build(final BuildContext context) {
    final state = _useScreenState(read: context.read);
    final theme = Theme.of(context);
    final uiTheme = UiTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: state.leftWidth,
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
              ],
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
