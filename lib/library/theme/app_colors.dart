part of theme;

/// This class is responsible for all colours in the application
/// If there is a need to add new one—open an issue to add to figma.
///
/// See [style guide](https://www.figma.com/file/ggehTTqGDzpUDnU3C1uzOA/?node-id=15%3A3)
class AppColors {
  /// This class is not meant to be instantiated or extended; this constructor
  /// prevents instantiation and extension.
  AppColors._();

  /// #F2F3F1
  static const white2 = Color(0xFFF2F3F1);

  /// #F8F9F7
  static const white = Color(0xFFF8F9F7);

  /// #FFF
  static const cleanWhite = Color(0xFFFFFFFF);

  /// #4CAF52
  static const primary = Color(0xFF4CAF52);

  /// #15781B
  static const primary1 = Color(0xFF15781B);

  /// #2D9434
  static const primary2 = Color(0xFF2D9434);

  /// #77CC7D
  static const primary3 = Color(0xFF77CC7D);

  /// #A9E2AD
  static const primary4 = Color(0xFFA9E2AD);

  /// #212121
  static const black = Color(0xFF212121);

  /// #000000
  static const cleanBlack = Color(0xFF000000);

  /// #424242
  static const grey1 = Color(0xFF424242);

  /// #6B6B6B
  static const grey2 = Color(0xFF6B6B6B);

  /// #A9A9A9
  static const grey3 = Color(0xFFA9A9A9);

  /// #CACACA
  static const grey4 = Color(0xFFCACACA);

  /// #991E1B
  static const accent1 = Color(0xFF991E1B);

  /// #BD3D3A
  static const accent2 = Color(0xFFBD3D3A);

  /// #DE6461
  static const accent3 = Color(0xFFDE6461);

  /// #FF9895
  static const accent4 = Color(0xFFFF9895);

  /// #FFBFBD
  static const accent5 = Color(0xFFFFBFBD);

  /// #1D9BF0
  static const twitterBlue = Color(0xFF1D9BF0);
}
