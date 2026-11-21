import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

import 'package:lastanswer/foundation/file_service/file_service_i.dart';

class FileService implements FileServiceI {
  @override
  Future<Map<String, dynamic>> openFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return {};
    final file = result.files.first;
    final bytes = await file.readAsBytes();
    final s = const Utf8Decoder().convert(bytes.toList());
    return jsonDecode(s);
  }

  @override
  Future<bool> saveFile({
    required final Map<String, dynamic> data,
    required final String filename,
  }) async {
    final result = await getSaveLocation(suggestedName: filename);
    // Operation was canceled by the user.
    if (result == null) return false;
    final str = jsonEncode(data);
    final uint8List = const Utf8Encoder().convert(str);
    const String mimeType = 'text/json';
    final XFile textFile = XFile.fromData(
      uint8List,
      mimeType: mimeType,
      name: filename,
    );
    await textFile.saveTo(result.path);
    return true;
  }

  @override
  Future<bool> saveFileBytes({
    required final List<int> bytes,
    required final String filename,
  }) async {
    final result = await getSaveLocation(suggestedName: filename);
    // Operation was canceled by the user.
    if (result == null) return false;
    const String mimeType = 'application/zip';
    final XFile zipFile = XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: mimeType,
      name: filename,
    );
    await zipFile.saveTo(result.path);
    return true;
  }

  @override
  Future<List<int>?> openFileBytes() async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return null;
    return result.files.first.readAsBytes();
  }
}
