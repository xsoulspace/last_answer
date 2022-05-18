part of pack_core;

abstract class Deletable {
  /// This property is used to mark instance
  /// as to be deleted in the server side.
  ///
  /// The principle is that once internet connection
  /// is established, the instance should be deleted.
  bool isToDelete = false;
}
