import 'dart:convert';

import 'package:shared_models/shared_models.dart';
import 'package:universal_io/io.dart';

abstract interface class FileServiceI {
  static String get filename => 'last_answer_${todayDateTime.yyyyMMDD}.json';
  Future<List> openFile();
  Future<void> saveFile(final List<Map<String, dynamic>> data);
}

extension FileServiceIX on FileServiceI {
  void saveFileData({
    required final String? filePath,
    required final List<Map<String, dynamic>> data,
  }) {
    // User canceled the picker
    if (filePath == null) return;
    final file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file
      ..createSync()
      ..writeAsStringSync(jsonEncode(data));
  }
}
