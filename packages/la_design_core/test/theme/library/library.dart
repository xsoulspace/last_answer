import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:la_design_core/la_design_core.dart';
import 'package:la_design_core/src/theme/data/form_factor.dart';
import 'package:la_design_core/src/theme/responsive_theme.dart';
import 'package:la_design_core/src/utils/named.dart';
import 'package:la_design_core/src/widgets/base/icon.dart';

import 'base.dart';

part 'colors.dart';
part 'icons.dart';
part 'radius.dart';
part 'shadows.dart';
part 'spacing.dart';
part 'typography.dart';

class AppThemeLibrary extends StatelessWidget {
  const AppThemeLibrary({
    Key? key,
    required this.colorMode,
    required this.formFactor,
  }) : super(key: key);

  final AppThemeColorMode colorMode;
  final AppFormFactor formFactor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppResponsiveTheme(
        appLogo: StringPicture(
          SvgPicture.svgStringDecoderBuilder,
          '<svg></svg>',
        ),
        colorMode: colorMode,
        formFactor: formFactor,
        child: Builder(
          builder: (context) {
            return ThemeContainer(
              title: 'Asgard Theme : ${formFactor.name} - ${colorMode.name}',
              sections: [
                colors(context),
                typography(context),
                icons(context),
                radius(context),
                spacing(context),
                shadow(context),
              ],
            );
          },
        ),
      ),
    );
  }
}
