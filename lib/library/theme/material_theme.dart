part of theme;

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
      statusBarBrightness: Brightness.light,
      statusBarColor: _lightBase.canvasColor,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  inputDecorationTheme: _lightBase.inputDecorationTheme.copyWith(
    isDense: true,
  ),
);
