part of utils;

enum ThemeToUse {
  fromContext,
  nativeDark,
  nativeLight,
}

class ThemeDefiner {
  ThemeDefiner.of(this.context);
  final BuildContext context;
  ThemeData get effectiveTheme {
    switch (themeToUse) {
      case ThemeToUse.nativeDark:
        return darkThemeData;
      case ThemeToUse.nativeLight:
        return lightThemeData;
      case ThemeToUse.fromContext:
        return Theme.of(context);
    }
  }

  ThemeToUse get themeToUse {
    if (isNativeDesktop && nativeTransparentBackgroundSupported) {
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      switch (platformBrightness) {
        case Brightness.dark:
          return ThemeToUse.nativeDark;
        case Brightness.light:
          return ThemeToUse.nativeLight;
      }
    } else {
      return ThemeToUse.fromContext;
    }
  }

  bool get useDarkTheme => themeToUse == ThemeToUse.nativeDark;

  bool get useContextTheme => themeToUse == ThemeToUse.fromContext;
}
