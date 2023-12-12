extension DoubleExtension on int {
  void onPositive(final void Function(int value) callback) =>
      this <= 0 ? null : callback(this);
}

extension IntExtension on double {
  void onPositive(final void Function(double value) callback) =>
      this <= 0 ? null : callback(this);
}
