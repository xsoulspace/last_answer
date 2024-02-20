import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:universal_io/io.dart';

import '../../../core.dart';
import 'file_service_i.dart';

class FileService implements FileServiceI {
  final _instance =
      PlatformInfo.isNativeDesktop ? FileServiceDesktop() : FileServiceMobile();

  @override
  Future<List> openFile() => _instance.openFile();
  @override
  Future<void> saveFile({
    required final List<Map<String, dynamic>> data,
    required final String filename,
  }) =>
      _instance.saveFile(data: data, filename: filename);
}

class FileServiceMobile implements FileServiceI {
  @override
  Future<List> openFile() async {
    await FilePicker.platform.clearTemporaryFiles();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return [];
    final file = result.files.first;
    final dataStr = File(file.path!).readAsStringSync();
    return jsonDecode(dataStr);
  }

  @override
  Future<void> saveFile({
    required final List<Map<String, dynamic>> data,
    required final String filename,
  }) async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select directory to save file',
    );
    if (path == null || path.isEmpty) return;
    final dir = Directory(path);
    if (!dir.existsSync()) dir.createSync();

    saveFileData(filePath: '$path/$filename', data: data);
  }
}

class FileServiceDesktop implements FileServiceI {
  @override
  Future<List> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    // User canceled the picker
    if (result == null) return [];

    final dataStr = File(result.files.single.path!).readAsStringSync();
    return jsonDecode(dataStr);
  }

  @override
  Future<void> saveFile({
    required final List<Map<String, dynamic>> data,
    required final String filename,
  }) async {
    final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Select directory to save file',
      type: FileType.custom,
      allowedExtensions: ['json'],
      fileName: filename,
    );
    saveFileData(filePath: filePath, data: data);
  }
}
