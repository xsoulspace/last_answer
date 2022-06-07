import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import '../../theme/theme.dart';

enum AppGapSize {
  none,
  small,
  semiSmall,
  regular,
  semiBig,
  big,
}

extension AppGapSizeExtension on AppGapSize {
  double getSpacing(final AppThemeData theme) {
    switch (this) {
      case AppGapSize.none:
        return 0;
      case AppGapSize.small:
        return theme.spacing.small;
      case AppGapSize.semiSmall:
        return theme.spacing.semiSmall;
      case AppGapSize.regular:
        return theme.spacing.regular;
      case AppGapSize.semiBig:
        return theme.spacing.semiBig;
      case AppGapSize.big:
        return theme.spacing.big;
    }
  }
}

class AppGap extends StatelessWidget {
  const AppGap(
    this.size, {
    final Key? key,
  }) : super(key: key);

  const AppGap.small({
    final Key? key,
  })  : size = AppGapSize.small,
        super(key: key);

  const AppGap.semiSmall({
    final Key? key,
  })  : size = AppGapSize.semiSmall,
        super(key: key);

  const AppGap.regular({
    final Key? key,
  })  : size = AppGapSize.regular,
        super(key: key);

  const AppGap.semiBig({
    final Key? key,
  })  : size = AppGapSize.semiBig,
        super(key: key);

  const AppGap.big({
    final Key? key,
  })  : size = AppGapSize.big,
        super(key: key);

  final AppGapSize size;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);
    return Gap(size.getSpacing(theme));
  }
}
