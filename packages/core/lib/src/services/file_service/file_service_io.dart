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
  Future<void> saveFile(final List<Map<String, dynamic>> data) =>
      _instance.saveFile(data);
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
  Future<void> saveFile(final List<Map<String, dynamic>> data) async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select directory to save file',
    );
    if (path == null || path.isEmpty) return;
    final dir = Directory(path);
    if (!dir.existsSync()) dir.createSync();

    _saveFileData(filePath: '$path/${FileServiceI.filename}', data: data);
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
  Future<void> saveFile(final List<Map<String, dynamic>> data) async {
    final String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Select directory to save file',
      type: FileType.custom,
      allowedExtensions: ['json'],
      fileName: FileServiceI.filename,
    );
    _saveFileData(filePath: filePath, data: data);
  }
}

extension _FileServiceIX on FileServiceI {
  void _saveFileData({
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
