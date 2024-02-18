extension DateTimeX on DateTime {
  DateTime get onlyDate => DateTime(year, month, day);
  String get yyyyMMDD => '$year.$month.${day}_h$hour-m$minute';
}

final todayDate = todayDateTime.onlyDate;
final todayDateTime = DateTime.now();
