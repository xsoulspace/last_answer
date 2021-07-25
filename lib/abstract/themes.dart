import 'package:lastanswer/utils/utils.dart';

/// Use this enum to control app theme
enum Themes {
  light,
  dark,

  /// Returns [Enum] from string.
  ///
  /// {@macro enum_to_string_value}
  fromString,
}

/// Use ThemesExt to extend [Themes]
extension ThemesExt on Themes {
  /// {@macro enum_from_string}
  Themes operator [](final String value) => getEnumValueFromEnumValues(
        values: Themes.values,
        value: value,
      );
}
