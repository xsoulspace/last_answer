import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';

part 'app/colors.dart';
part 'app/typography.dart';
part 'brand/color_schemes.dart';
part 'brand/typography.dart';
part 'data/ui_form_factor.dart';
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
    required final UiBoxSpacing gaps,
    required final UiRadius circularRadius,
    required final UiTextTheme text,
    required final UiPersistentFormFactors persistentFormFactors,
    required final UiCustomizableFormFactors customizableFormFactors,
  }) = _UiThemeScheme;
  const UiThemeScheme._();
  factory UiThemeScheme.m3(final BuildContext context) {
    const spacing = UiSpacing.m3;
    return UiThemeScheme(
      text: UiTextTheme.of(context),
      customizableFormFactors: UiCustomizableFormFactors.ofTargetPlatform(),
      persistentFormFactors: UiPersistentFormFactors.of(context),
      circularRadius: UiRadius.circularBySpacing(spacing: spacing),
      spacing: spacing,
      gaps: UiBoxSpacing.fromSpacing(spacing: spacing),
    );
  }
}

extension UiThemeBuildContextExtension on BuildContext {
  UiThemeScheme get uiTheme => UiTheme.of(this);
}

class UiTheme extends InheritedWidget {
  const UiTheme({
    required this.scheme,
    required super.child,
    super.key,
  });

  final UiThemeScheme scheme;

  static UiThemeScheme of(final BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<UiTheme>();
    return widget!.scheme;
  }

  @override
  bool updateShouldNotify(covariant final UiTheme oldWidget) =>
      scheme != oldWidget.scheme;
}
