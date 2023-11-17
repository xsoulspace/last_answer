import 'package:isar/isar.dart';

mixin IsarEquatableMixin {
  /// Encoded model content
  String jsonContent = '';

  String modelIdStr = '';

  /// should be generated from [modelIdStr]
  int modelIdHashcode = 0;
  Id get isarId => modelIdHashcode;
}
