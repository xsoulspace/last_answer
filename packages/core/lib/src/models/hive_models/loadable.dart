part of 'hive_models.dart';

abstract class Loadable {
  Loadable();

  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad({required final BuildContext context});
}
