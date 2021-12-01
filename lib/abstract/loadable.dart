part of abstract;

abstract class Loadable {
  Loadable();

  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad();
}
