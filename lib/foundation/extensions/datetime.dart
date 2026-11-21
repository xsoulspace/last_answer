/// Date/time formatting helpers (moved from packages/shared_models
/// foundation, ADR 0038).
extension DateTimeX on DateTime {
  /// Date-only midnight of this instant.
  DateTime get onlyDate => DateTime(year, month, day);

  /// Compact `year.month.day_hh-mm` stamp (backup file names).
  String get yyyyMMDD => '$year.$month.${day}_h$hour-m$minute';
}

/// Today's date at midnight.
final todayDate = todayDateTime.onlyDate;

/// A `DateTime.now()` captured at library load (backup naming).
final todayDateTime = DateTime.now();
