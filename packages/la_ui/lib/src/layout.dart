import 'package:flutter/widgets.dart';

/// Breakpoint helper over [MediaQuery] / [BoxConstraints] (moved here from
/// the retired legacy kit, 2026-11-19). Widgets-layer only.
class ScreenLayout {
  ScreenLayout._({this.context, this.constraints})
    : assert(
        context != null || constraints != null,
        'context or constraints should be filled',
      );
  factory ScreenLayout.from(final BoxConstraints constraints) =>
      ScreenLayout._(constraints: constraints);
  factory ScreenLayout.of(final BuildContext context) =>
      ScreenLayout._(context: context);

  final BuildContext? context;
  final BoxConstraints? constraints;
  static const maxFullscreenPageWidth = 500.0;
  static const minFullscreenPageWidth = 450.0;
  static const maxSmallWidth = minFullscreenPageWidth;
  static const maxMediumWidth = 1000.0;

  Size get size {
    if (constraints != null) {
      return Size(constraints!.maxWidth, constraints!.maxHeight);
    }

    return MediaQuery.sizeOf(context!);
  }

  //Large screen is any screen whose width is more than 1200 pixels
  bool get large => size.width > maxMediumWidth;

  //Medium screen is any screen whose width is less than 1200 pixels,
  //and more than 800 pixels
  bool get medium => size.width > maxSmallWidth && size.width < maxMediumWidth;

  //Small screen is any screen whose width is less than 800 pixels
  bool get small => size.width < maxSmallWidth;
  bool get notSmall => size.width > maxSmallWidth;
}

/// Bottom-edge safe-area spacer (moved from the retired legacy kit).
class BottomSafeArea extends StatelessWidget {
  const BottomSafeArea({super.key});
  @override
  Widget build(final BuildContext context) =>
      const SafeArea(top: false, child: SizedBox(height: 1));
}

/// Top-edge safe-area spacer (moved from the retired legacy kit).
class TopSafeArea extends StatelessWidget {
  const TopSafeArea({super.key});
  @override
  Widget build(final BuildContext context) =>
      const SafeArea(bottom: false, child: SizedBox(height: 1));
}
