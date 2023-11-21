import 'package:isar/isar.dart';

mixin IsarEquatableMixin {
  /// Encoded model content
  String jsonContent = '';

  @Id()
  String modelIdStr = '';
}
