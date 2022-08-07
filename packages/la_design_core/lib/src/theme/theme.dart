import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app/colors.dart';
part 'app/typography.dart';
part 'brand/color_schemes.dart';
part 'brand/typography.dart';
part 'data/ui_layout.dart';
part 'data/ui_text_theme.dart';
part 'theme.freezed.dart';

@immutable
@Freezed(
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UiThemeScheme with _$UiThemeScheme {
  const factory UiThemeScheme({
    required final UiSpacing spacing,
    required final UiBoxSpacing horizontalBoxes,
    required final UiBoxSpacing verticalBoxes,
    required final UiRadius circularRadius,
    required final UiTextTheme text,
  }) = _UiThemeScheme;
  const UiThemeScheme._();
  factory UiThemeScheme.m3(final BuildContext context) {
    const spacing = UiSpacing.m3;
    return UiThemeScheme(
      text: UiTextTheme.of(context),
      circularRadius: UiRadius.circularBySpacing(spacing: spacing),
      spacing: spacing,
      horizontalBoxes: UiBoxSpacing.horizontal(spacing: spacing),
      verticalBoxes: UiBoxSpacing.vertical(spacing: spacing),
    );
  }
}

class UiTheme extends InheritedWidget {
  const UiTheme({
    required this.scheme,
    required final super.child,
    final super.key,
  });

  final UiThemeScheme scheme;

  static UiThemeScheme of(final BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<UiTheme>();
    return widget!.scheme;
  }

  @override
  bool updateShouldNotify(covariant final UiTheme oldWidget) {
    return scheme != oldWidget.scheme;
  }
}
