import 'package:flutter/material.dart';
import 'package:lastanswer/library/widgets/buttons/adaptive_back_button.dart';
import 'package:lastanswer/library/widgets/core/responsive_widget.dart';
import 'package:lastanswer/library/widgets/core/safe_areas.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:universal_io/io.dart';

class LeftPanelMacosAppBar extends AppBar {
  LeftPanelMacosAppBar({
    required final BuildContext context,
    final String title = '',
    final List<Widget>? actions,
    final Key? key,
  }) : super(
          actions: actions,
          leadingWidth: 0,
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: title.isNotEmpty
                ? [
                    const TopSafeArea(),
                    const SizedBox(height: 9),
                    SelectableText(
                      title,
                      textAlign: TextAlign.left,
                      style: ThemeDefiner.of(context)
                          .effectiveTheme
                          .textTheme
                          .subtitle1
                          ?.copyWith(fontSize: 16),
                    ),
                  ]
                : [],
          ),
          key: key,
        );
}

class BackTextUniversalAppBar extends AppBar {
  BackTextUniversalAppBar({
    required final VoidCallback onBack,
    final ScreenLayout? screenLayout,
    final List<Widget>? actions,
    final String? titleStr,
    final Widget? title,
    final Key? key,
    final bool useBackButton = false,
    final double? height,
  })  : assert(
          titleStr != null || title != null,
          'Title or title str should not be empty',
        ),
        super(
          toolbarHeight: height ?? (Platform.isMacOS ? 70 : null),
          leading: (screenLayout?.small ?? true)
              ? _AppBarLeading(
                  onBack: onBack,
                  useBackButton: useBackButton,
                )
              : null,
          centerTitle: true,
          title: title ?? Text(titleStr ?? ''),
          key: key,
          actions: actions,
        );
}

class _AppBarLeading extends StatelessWidget {
  const _AppBarLeading({
    required this.useBackButton,
    required this.onBack,
    final Key? key,
  }) : super(key: key);
  final bool useBackButton;
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final backButton = useBackButton
        ? AdaptiveBackButton(onPressed: onBack)
        : CloseButton(onPressed: onBack);
    if (Platform.isMacOS) {
      return Column(
        children: [
          const TopSafeArea(),
          const SizedBox(height: 25),
          backButton,
        ],
      );
    }

    return backButton;
  }
}
