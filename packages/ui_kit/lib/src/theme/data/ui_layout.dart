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
    none: 0,
    extraSmall: 2,
    small: 4,
    medium: 12,
    large: 24,
    extraLarge: 36,
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
  }) =>
      UiRadius(
        extraLarge: Radius.circular(spacing.extraLarge),
        extraSmall: Radius.circular(spacing.extraSmall),
        full: Radius.circular(spacing.full),
        large: Radius.circular(spacing.large),
        medium: Radius.circular(spacing.medium),
        none: Radius.circular(spacing.none),
        small: Radius.circular(spacing.small),
      );
}

@immutable
@Freezed(
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UiBoxSpacing with _$UiBoxSpacing {
  const factory UiBoxSpacing({
    required final Widget none,
    required final Widget extraSmall,
    required final Widget small,
    required final Widget medium,
    required final Widget large,
    required final Widget extraLarge,
    required final Widget full,
  }) = _UiBoxSpacing;
  const UiBoxSpacing._();
  factory UiBoxSpacing.fromSpacing({
    required final UiSpacing spacing,
  }) =>
      UiBoxSpacing(
        none: const SizedBox(),
        extraSmall: spacing.extraSmall.toGap,
        small: spacing.small.toGap,
        medium: spacing.medium.toGap,
        large: spacing.large.toGap,
        extraLarge: spacing.extraLarge.toGap,
        full: spacing.full.toGap,
      );
}

extension DoubleExt on double {
  Gap get toGap => Gap(this);
}
