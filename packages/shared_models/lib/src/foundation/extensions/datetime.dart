extension DateTimeX on DateTime {
  DateTime get onlyDate => DateTime(year, month, day);
}

final todayDate = DateTime.now().onlyDate;
