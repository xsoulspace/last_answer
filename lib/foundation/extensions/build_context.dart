import 'package:lastanswer/common_imports.dart';
import 'package:material_ui/material_ui.dart' show ColorScheme, TextTheme, Theme, ThemeData;

extension BuildContextExtension on BuildContext {
  S get l10n => S.of(this);
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  GoRouter get router => GoRouter.of(this);
  Locale get locale => uiLocaleNotifier.value;
}
