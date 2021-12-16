part of 'utils.dart';

/// This extension for common enum functions
extension EnumExt on Enum {
  /// Returns a short description of an enum value.
  /// {@macro enum_to_string_value}
  /// {@macro enum_from_string}
  String toStringValue() => describeEnum(this);
}

/// Use this function to override operator [] for enum
/// {@template enum_from_string}
/// for example:
/// ```
/// Themes operator [](final String value) => getEnumValueFromEnumValues(
///     values: Themes.values,
///     value: value,
///   );
/// ```
/// {@endtemplate}
///
/// To convert enum value to [String] use
/// [Enum.toString] or [Enum.toStringValue]
///
/// More details see below:
/// {@template enum_to_string_value}
///
/// ```
/// enum Themes{
///   light,
///   fromString,
/// }
///
/// assert(Themes.light.toString() == 'Themes.light');
/// assert(Themes.light.toStringValue() == 'light');
/// ```
///
/// To convert back use:
/// ```
/// assert(Themes.fromString['Themes.light'] == Themes.light);
/// ```
/// Make sure that you override operator [] for [Themes]
/// {@endtemplate}
E getEnumValueFromEnumValues<E extends Enum>({
  required final List<E> values,
  required final String value,
}) {
  final resolvedValue = values.firstWhereOrNull(
    (final element) => element.toString() == value,
  );

  if (resolvedValue == null) {
    throw RangeError(
      "enum ${E.runtimeType} contains no value '$value'",
    );
  }

  return resolvedValue;
}
