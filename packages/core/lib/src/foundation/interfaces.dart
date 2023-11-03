abstract class Disposable {
  Disposable._();
  void dispose();
}

abstract class Loadable {
  Loadable._();

  /// Use this function to load something on
  /// instance initialization
  Future<void> onLoad();
}
