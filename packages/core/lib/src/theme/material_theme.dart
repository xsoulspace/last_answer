part of 'theme.dart';

/// The shipped themes (phase 0 of docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md): the DESIGN.md token table
/// as a real [ThemeData], replacing the stock `ThemeData.light()/dark()` the
/// app carried since the pivot. Colors come from [LaPalette] only; the type
/// scale from [LaTokens]; Material's ink effects are switched off globally
/// (the shell is de-Material by law, and legacy surfaces get quiet fills
/// instead of ripples until phase 4 restyles them).
ThemeData _laTheme(final Brightness brightness) {
  final p = LaPalette.of(brightness);
  final onAccent = p.isDark ? p.canvas : const Color(0xFFFFFFFF);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.accent,
    onPrimary: onAccent,
    primaryContainer: p.surfaceRaised,
    onPrimaryContainer: p.ink,
    secondary: p.accent,
    onSecondary: onAccent,
    secondaryContainer: p.surfaceRaised,
    onSecondaryContainer: p.ink,
    tertiary: p.caution,
    onTertiary: p.canvas,
    error: p.danger,
    onError: p.isDark ? p.canvas : const Color(0xFFFFFFFF),
    errorContainer: p.danger.withValues(alpha: 0.16),
    onErrorContainer: p.danger,
    surface: p.surface,
    onSurface: p.ink,
    surfaceDim: p.canvas,
    surfaceBright: p.surfaceRaised,
    surfaceContainerLowest: p.canvas,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surfaceRaised,
    surfaceContainerHigh: p.surfaceRaised,
    surfaceContainerHighest: p.surfaceOverlay,
    onSurfaceVariant: p.inkMuted,
    outline: p.rule,
    outlineVariant: p.rule.withValues(alpha: 0.6),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: p.ink,
    onInverseSurface: p.canvas,
    inversePrimary: p.accent,
  );
  final text = _laTextTheme(p);
  final quietShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(LaTokens.radius),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [LaThemeExtension(p)],
    scaffoldBackgroundColor: p.canvas,
    canvasColor: p.canvas,
    cardColor: p.surface,
    dividerColor: p.rule,
    dialogBackgroundColor: p.surfaceOverlay,
    indicatorColor: p.accent,
    hintColor: p.inkQuiet,
    disabledColor: p.inkQuiet.withValues(alpha: 0.6),
    splashFactory: NoSplash.splashFactory,
    highlightColor: const Color(0x00000000),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: text,
    iconTheme: IconThemeData(color: p.inkMuted, size: 18),
    primaryIconTheme: IconThemeData(color: p.ink, size: 18),
    appBarTheme: AppBarTheme(
      backgroundColor: p.surface,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleMedium,
      iconTheme: IconThemeData(color: p.inkMuted, size: 18),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: p.ink,
      unselectedLabelColor: p.inkMuted,
      indicatorColor: p.accent,
      dividerColor: p.rule,
      labelStyle: text.labelMedium,
      unselectedLabelStyle: text.labelMedium,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.ink,
        textStyle: text.labelLarge,
        shape: quietShape,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: onAccent,
        textStyle: text.labelLarge,
        shape: quietShape,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.surfaceRaised,
        foregroundColor: p.ink,
        elevation: 0,
        textStyle: text.labelLarge,
        shape: quietShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        side: BorderSide(color: p.rule),
        textStyle: text.labelLarge,
        shape: quietShape,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: p.inkMuted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      fillColor: p.ink.withValues(alpha: p.isDark ? 0.04 : 0.03),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaTokens.radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaTokens.radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaTokens.radius),
        borderSide: BorderSide(color: p.accent, width: LaTokens.hairline),
      ),
      hintStyle: text.bodyMedium?.copyWith(color: p.inkQuiet),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.surfaceOverlay,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.rule),
      ),
      textStyle: text.labelSmall?.copyWith(color: p.ink),
      waitDuration: const Duration(milliseconds: 600),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surfaceOverlay,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaTokens.radiusFloating),
        side: BorderSide(color: p.rule),
      ),
      textStyle: text.labelMedium,
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(p.surfaceOverlay),
        surfaceTintColor: const WidgetStatePropertyAll(Color(0x00000000)),
        elevation: const WidgetStatePropertyAll(0),
        side: WidgetStatePropertyAll(BorderSide(color: p.rule)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LaTokens.radiusFloating),
          ),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surfaceOverlay,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaTokens.radiusFloating),
        side: BorderSide(color: p.rule),
      ),
      titleTextStyle: text.titleMedium,
      contentTextStyle: text.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.surfaceOverlay,
      contentTextStyle: text.bodyMedium?.copyWith(color: p.ink),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaTokens.radius),
        side: BorderSide(color: p.rule),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.inkMuted,
      textColor: p.ink,
      titleTextStyle: text.bodyMedium,
      subtitleTextStyle: text.labelMedium?.copyWith(color: p.inkMuted),
      shape: quietShape,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surfaceRaised,
      selectedColor: p.accent.withValues(alpha: 0.18),
      side: BorderSide(color: p.rule),
      labelStyle: text.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.accent,
      linearMinHeight: 2,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
      thumbColor: WidgetStatePropertyAll(p.rule),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.accent,
      selectionColor: p.accent.withValues(alpha: 0.28),
      selectionHandleColor: p.accent,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(p.accent),
      trackColor: WidgetStatePropertyAll(p.rule),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStatePropertyAll(p.accent),
      checkColor: WidgetStatePropertyAll(onAccent),
      side: BorderSide(color: p.inkQuiet),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStatePropertyAll(p.accent),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.accent,
      thumbColor: p.accent,
      inactiveTrackColor: p.rule,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LaTokens.radiusFloating),
        ),
      ),
    ),
  );
}

final ThemeData lightThemeData = _laTheme(Brightness.light);
final ThemeData darkThemeData = _laTheme(Brightness.dark);
