import 'dart:convert';

import 'package:isar/isar.dart';

mixin IsarEquatableMixin {
  /// Encoded model content
  String jsonContent = '';

  @Id()
  String modelIdStr = '';
  Map<String, dynamic> get jsonMap =>
      jsonDecode(jsonContent) as Map<String, dynamic>;
}
