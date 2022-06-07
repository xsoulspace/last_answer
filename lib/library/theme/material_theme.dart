import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lastanswer/library/theme/app_colors.dart';
import 'package:lastanswer/library/theme/app_text_styles.dart';
import 'package:lastanswer/library/theme/color_scheme.dart';
import 'package:lastanswer/utils/utils.dart';

final _lightBase = ThemeData.from(
  colorScheme: lightColorScheme,
  textTheme: lightTextTheme,
);

final lightThemeData = _lightBase.copyWith(
  appBarTheme: _lightBase.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: AppColors.black,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: _lightBase.canvasColor,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),

  visualDensity: VisualDensity.adaptivePlatformDensity,
  scrollbarTheme: _lightBase.scrollbarTheme.copyWith(
    showTrackOnHover: false,
    thumbVisibility: MaterialStateProperty.all(false),
    interactive: true,
    // crossAxisMargin: -6,
    thumbColor: MaterialStateProperty.all(AppColors.grey1.withOpacity(0.4)),
    trackBorderColor:
        MaterialStateProperty.all(AppColors.grey4.withOpacity(0.2)),
  ),
  // scaffoldBackgroundColor: Colors.transparent,
  scaffoldBackgroundColor:
      isNativeDesktop && nativeTransparentBackgroundSupported
          ? Colors.transparent
          : _lightBase.scaffoldBackgroundColor,
  inputDecorationTheme: _lightBase.inputDecorationTheme.copyWith(
    isDense: true,
  ),
);

final _darkBase = ThemeData.from(
  colorScheme: darkColorScheme,
  textTheme: darkTextTheme,
);

final darkThemeData = _darkBase.copyWith(
  appBarTheme: _darkBase.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: AppColors.white,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: _darkBase.canvasColor,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  scrollbarTheme: _darkBase.scrollbarTheme.copyWith(
    interactive: true,
    showTrackOnHover: false,
    thumbVisibility: MaterialStateProperty.all(false),
    // crossAxisMargin: -6,
    thumbColor: MaterialStateProperty.all(AppColors.grey4.withOpacity(0.4)),
    // trackBorderColor: MaterialStateProperty.all(AppColors.cleanBlack),
    // trackColor: MaterialStateProperty.all(AppColors.grey1.withOpacity(0.1)),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  // scaffoldBackgroundColor: Colors.transparent,
  scaffoldBackgroundColor:
      isNativeDesktop && nativeTransparentBackgroundSupported
          ? Colors.transparent
          : _darkBase.scaffoldBackgroundColor,
  cardColor: AppColors.grey1.withOpacity(0.5),
  splashColor: AppColors.primary2.withOpacity(0.4),
  inputDecorationTheme: _lightBase.inputDecorationTheme.copyWith(
    isDense: true,
  ),
);
