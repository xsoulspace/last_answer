import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:shared_models/shared_models.dart';
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
  Future<List> openFile() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveFile(final List<Map<String, dynamic>> data) {
    throw UnimplementedError();
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
      dialogTitle: 'Please select an output file:',
      type: FileType.custom,
      allowedExtensions: ['json'],
      fileName: 'last_answer_${todayDate.yyyyMMDD}.json',
    );

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
