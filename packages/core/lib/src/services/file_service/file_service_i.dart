import 'dart:convert';

import 'package:shared_models/shared_models.dart';
import 'package:universal_io/io.dart';

abstract interface class FileServiceI {
  static String get filenameWithTimestamp =>
      'last_answer_${todayDateTime.yyyyMMDD}.json';
  static const filename = 'last_answer.json';
  Future<Map<String, dynamic>> openFile();
  Future<bool> saveFile({
    required final Map<String, dynamic> data,
    required final String filename,
  });
}

extension FileServiceIX on FileServiceI {
  bool saveFileData({
    required final String? filePath,
    required final Map<String, dynamic> data,
  }) {
    // User canceled the picker
    if (filePath == null) return false;
    final file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file
      ..createSync()
      ..writeAsStringSync(jsonEncode(data));
    return true;
  }
}
