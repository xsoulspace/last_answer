/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// ignore_for_file: directives_ordering

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class $GoogleFontsGen {
  const $GoogleFontsGen();

  /// File path: google_fonts/IBMPlexSans-Bold.ttf
  String get iBMPlexSansBold => 'google_fonts/IBMPlexSans-Bold.ttf';

  /// File path: google_fonts/IBMPlexSans-BoldItalic.ttf
  String get iBMPlexSansBoldItalic => 'google_fonts/IBMPlexSans-BoldItalic.ttf';

  /// File path: google_fonts/IBMPlexSans-ExtraLight.ttf
  String get iBMPlexSansExtraLight => 'google_fonts/IBMPlexSans-ExtraLight.ttf';

  /// File path: google_fonts/IBMPlexSans-ExtraLightItalic.ttf
  String get iBMPlexSansExtraLightItalic =>
      'google_fonts/IBMPlexSans-ExtraLightItalic.ttf';

  /// File path: google_fonts/IBMPlexSans-Italic.ttf
  String get iBMPlexSansItalic => 'google_fonts/IBMPlexSans-Italic.ttf';

  /// File path: google_fonts/IBMPlexSans-Light.ttf
  String get iBMPlexSansLight => 'google_fonts/IBMPlexSans-Light.ttf';

  /// File path: google_fonts/IBMPlexSans-LightItalic.ttf
  String get iBMPlexSansLightItalic =>
      'google_fonts/IBMPlexSans-LightItalic.ttf';

  /// File path: google_fonts/IBMPlexSans-Medium.ttf
  String get iBMPlexSansMedium => 'google_fonts/IBMPlexSans-Medium.ttf';

  /// File path: google_fonts/IBMPlexSans-MediumItalic.ttf
  String get iBMPlexSansMediumItalic =>
      'google_fonts/IBMPlexSans-MediumItalic.ttf';

  /// File path: google_fonts/IBMPlexSans-Regular.ttf
  String get iBMPlexSansRegular => 'google_fonts/IBMPlexSans-Regular.ttf';

  /// File path: google_fonts/IBMPlexSans-SemiBold.ttf
  String get iBMPlexSansSemiBold => 'google_fonts/IBMPlexSans-SemiBold.ttf';

  /// File path: google_fonts/IBMPlexSans-SemiBoldItalic.ttf
  String get iBMPlexSansSemiBoldItalic =>
      'google_fonts/IBMPlexSans-SemiBoldItalic.ttf';

  /// File path: google_fonts/IBMPlexSans-Thin.ttf
  String get iBMPlexSansThin => 'google_fonts/IBMPlexSans-Thin.ttf';

  /// File path: google_fonts/IBMPlexSans-ThinItalic.ttf
  String get iBMPlexSansThinItalic => 'google_fonts/IBMPlexSans-ThinItalic.ttf';

  /// File path: google_fonts/NotoColorEmoji.ttf
  String get notoColorEmoji => 'google_fonts/NotoColorEmoji.ttf';

  /// File path: google_fonts/NotoSans-Bold.ttf
  String get notoSansBold => 'google_fonts/NotoSans-Bold.ttf';

  /// File path: google_fonts/NotoSans-BoldItalic.ttf
  String get notoSansBoldItalic => 'google_fonts/NotoSans-BoldItalic.ttf';

  /// File path: google_fonts/NotoSans-Italic.ttf
  String get notoSansItalic => 'google_fonts/NotoSans-Italic.ttf';

  /// File path: google_fonts/NotoSans-Regular.ttf
  String get notoSansRegular => 'google_fonts/NotoSans-Regular.ttf';

  /// File path: google_fonts/OFL.txt
  String get ofl => 'google_fonts/OFL.txt';
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/idea.svg
  SvgGenImage get idea => const SvgGenImage('assets/icons/idea.svg');

  /// File path: assets/icons/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/icons/logo.png');

  /// File path: assets/icons/logo_windows.png
  AssetGenImage get logoWindows =>
      const AssetGenImage('assets/icons/logo_windows.png');
}

class Assets {
  Assets._();

  static const String emojis = 'assets/emojis.json';
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const String specialEmoji = 'assets/special_emoji.json';
  static const $GoogleFontsGen googleFonts = $GoogleFontsGen();
}

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName);

  Image image({
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return SvgPicture.asset(
      _assetName,
      key: key,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      color: color,
      colorBlendMode: colorBlendMode,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
    );
  }

  String get path => _assetName;
}
