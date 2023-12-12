import 'package:flutter/cupertino.dart';
import 'package:lastanswer/common_imports.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    required this.onInfoTap,
    required this.onSettingsTap,
    super.key,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;
  @override
  Widget build(final BuildContext context) {
    final greeting = Greeting();
    // final themeDefiner = ThemeDefiner.of(context);
    // final effectiveTheme = themeDefiner.effectiveTheme;

    // if (Platform.isMacOS) {
    //   return LeftPanelMacosAppBar(
    //     context: context,
    //     title: greeting.current,
    //     actions: [
    //       IconButton(
    //         onPressed: onInfoTap,
    //         icon: const Icon(Icons.info_outline),
    //       ),
    //       IconButton(
    //         onPressed: onSettingsTap,
    //         icon: const Icon(CupertinoIcons.settings),
    //       ),
    //     ]
    //         .map(
    //           (final child) => Padding(
    //             padding: const EdgeInsets.only(right: 18),
    //             child: child,
    //           ),
    //         )
    //         .toList(),
    //   );
    // }

    return AppBar(
      title: SelectableText(
        greeting.current,
        style: context.textTheme.labelSmall,
      ),
      actions: [
        IconButton(
          onPressed: onInfoTap,
          icon: const Icon(Icons.info_outline),
        ),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(CupertinoIcons.gear),
        ),
      ]
          .map(
            (final child) => Padding(
              padding: const EdgeInsets.only(right: 18),
              child: child,
            ),
          )
          .toList(),
    );
  }
}
