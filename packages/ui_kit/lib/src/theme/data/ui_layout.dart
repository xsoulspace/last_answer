part of '../theme.dart';

@immutable
@Freezed(
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UiSpacing with _$UiSpacing {
  const factory UiSpacing({
    required final double none,
    required final double extraSmall,
    required final double small,
    required final double medium,
    required final double large,
    required final double extraLarge,
    required final double full,
  }) = _UiSpacing;
  const UiSpacing._();
  static const m3 = UiSpacing(
    none: 0.0,
    extraSmall: 2.0,
    small: 4.0,
    medium: 12.0,
    large: 24.0,
    extraLarge: 36.0,
    full: double.infinity,
  );
}

@immutable
@Freezed(
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UiRadius with _$UiRadius {
  const factory UiRadius({
    required final Radius none,
    required final Radius extraSmall,
    required final Radius small,
    required final Radius medium,
    required final Radius large,
    required final Radius extraLarge,
    required final Radius full,
  }) = _UiRadius;
  const UiRadius._();
  @factory
  // ignore: prefer_constructors_over_static_methods
  static UiRadius circularBySpacing({
    required final UiSpacing spacing,
  }) {
    return UiRadius(
      extraLarge: Radius.circular(spacing.extraLarge),
      extraSmall: Radius.circular(spacing.extraSmall),
      full: Radius.circular(spacing.full),
      large: Radius.circular(spacing.large),
      medium: Radius.circular(spacing.medium),
      none: Radius.circular(spacing.none),
      small: Radius.circular(spacing.small),
    );
  }
}

@immutable
@Freezed(
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UiBoxSpacing with _$UiBoxSpacing {
  const factory UiBoxSpacing({
    required final SizedBox none,
    required final SizedBox extraSmall,
    required final SizedBox small,
    required final SizedBox medium,
    required final SizedBox large,
    required final SizedBox extraLarge,
    required final SizedBox full,
  }) = _UiBoxSpacing;
  const UiBoxSpacing._();
  @factory
  // ignore: prefer_constructors_over_static_methods
  static UiBoxSpacing vertical({
    required final UiSpacing spacing,
  }) =>
      UiBoxSpacing(
        none: spacing.none.toHeightBox,
        extraSmall: spacing.extraSmall.toHeightBox,
        small: spacing.small.toHeightBox,
        medium: spacing.medium.toHeightBox,
        large: spacing.large.toHeightBox,
        extraLarge: spacing.extraLarge.toHeightBox,
        full: spacing.full.toHeightBox,
      );

  @factory
  // ignore: prefer_constructors_over_static_methods
  static UiBoxSpacing horizontal({
    required final UiSpacing spacing,
  }) =>
      UiBoxSpacing(
        none: spacing.none.toWidthBox,
        extraSmall: spacing.extraSmall.toWidthBox,
        small: spacing.small.toWidthBox,
        medium: spacing.medium.toWidthBox,
        large: spacing.large.toWidthBox,
        extraLarge: spacing.extraLarge.toWidthBox,
        full: spacing.full.toWidthBox,
      );
}

extension DoubleExt on double {
  SizedBox get toHeightBox => SizedBox(height: this);
  SizedBox get toWidthBox => SizedBox(width: this);
}
