part of '../theme.dart';

/// Common styles
@immutable
@Freezed(
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UiTextTheme with _$UiTextTheme {
  const factory UiTextTheme({
    required final TextTheme error,
  }) = _UiTextTheme;
  const UiTextTheme._();
  factory UiTextTheme.of(final BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextTheme = theme.textTheme;

    final errorColor = theme.colorScheme.error;
    final errorTheme = defaultTextTheme.copyWith(
      displayLarge: defaultTextTheme.displayLarge?.copyWith(
        color: errorColor,
      ),
      displayMedium: defaultTextTheme.displayMedium?.copyWith(
        color: errorColor,
      ),
      displaySmall: defaultTextTheme.displaySmall?.copyWith(
        color: errorColor,
      ),
      headlineLarge: defaultTextTheme.headlineLarge?.copyWith(
        color: errorColor,
      ),
      headlineMedium: defaultTextTheme.headlineMedium?.copyWith(
        color: errorColor,
      ),
      headlineSmall: defaultTextTheme.headlineSmall?.copyWith(
        color: errorColor,
      ),
      labelLarge: defaultTextTheme.labelLarge?.copyWith(
        color: errorColor,
      ),
      labelMedium: defaultTextTheme.labelMedium?.copyWith(
        color: errorColor,
      ),
      labelSmall: defaultTextTheme.labelSmall?.copyWith(
        color: errorColor,
      ),
      titleLarge: defaultTextTheme.titleLarge?.copyWith(
        color: errorColor,
      ),
      titleMedium: defaultTextTheme.titleMedium?.copyWith(
        color: errorColor,
      ),
      titleSmall: defaultTextTheme.titleSmall?.copyWith(
        color: errorColor,
      ),
      bodyLarge: defaultTextTheme.bodyLarge?.copyWith(
        color: errorColor,
      ),
      bodyMedium: defaultTextTheme.bodyMedium?.copyWith(
        color: errorColor,
      ),
      bodySmall: defaultTextTheme.bodySmall?.copyWith(
        color: errorColor,
      ),
    );
    return UiTextTheme(error: errorTheme);
  }
}
