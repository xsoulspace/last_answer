part of 'theme.dart';

final _lightBase = ThemeData.from(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary1),
  textTheme: textTheme,
  useMaterial3: true,
);

final lightThemeData = _lightBase.copyWith(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: _lightBase.inputDecorationTheme.copyWith(
    isDense: true,
  ),
);

final _darkBase = ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: AppColors.primary1,
  ),
  textTheme: textTheme,
  useMaterial3: true,
);

final darkThemeData = _darkBase.copyWith(
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: _lightBase.inputDecorationTheme.copyWith(
    isDense: true,
  ),
);
