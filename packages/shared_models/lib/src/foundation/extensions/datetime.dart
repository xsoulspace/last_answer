extension DateTimeX on DateTime {
  DateTime get onlyDate => DateTime(year, month, day);
  String get yyyyMMDD => '$year.$month.${day}_h$hour-m$minute';
}

final todayDate = DateTime.now().onlyDate;
