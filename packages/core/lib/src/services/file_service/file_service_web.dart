import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

import 'file_service_i.dart';

class FileService implements FileServiceI {
  @override
  Future<List> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return [];
    final file = result.files.first;
    final s = const Utf8Decoder().convert(file.bytes!.toList());
    return jsonDecode(s);
  }

  @override
  Future<bool> saveFile({
    required final List<Map<String, dynamic>> data,
    required final String filename,
  }) async {
    final result = await getSaveLocation(suggestedName: filename);
    // Operation was canceled by the user.
    if (result == null) return false;
    final str = jsonEncode(data);
    final uint8List = const Utf8Encoder().convert(str);
    const String mimeType = 'text/json';
    final XFile textFile =
        XFile.fromData(uint8List, mimeType: mimeType, name: filename);
    await textFile.saveTo(result.path);
    return true;
  }
}
