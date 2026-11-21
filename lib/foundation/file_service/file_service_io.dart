import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService implements FileServiceI {
  final _instance = PlatformInfo.isNativeDesktop
      ? FileServiceDesktop()
      : FileServiceMobile();

  @override
  Future<Map<String, dynamic>> openFile() => _instance.openFile();
  @override
  Future<bool> saveFile({
    required final Map<String, dynamic> data,
    required final String filename,
  }) => _instance.saveFile(data: data, filename: filename);
  @override
  Future<bool> saveFileBytes({
    required final List<int> bytes,
    required final String filename,
  }) => _instance.saveFileBytes(bytes: bytes, filename: filename);
  @override
  Future<List<int>?> openFileBytes() => _instance.openFileBytes();
}

class FileServiceMobile implements FileServiceI {
  @override
  Future<Map<String, dynamic>> openFile() async {
    await FilePicker.clearTemporaryFiles();

    /// json extension is not working on android
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return {};
    final file = result.files.first;
    final dataStr = File(file.path!).readAsStringSync();
    return jsonDecode(dataStr);
  }

  Future<bool> requestPermissions() async {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enables it in the system settings.
    if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
    }

    final status = await Permission.storage.request();

    final isGranted = switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.permanentlyDenied ||
      PermissionStatus.restricted => false,
      _ => true,
    };
    return isGranted;
  }

  @override
  Future<bool> saveFile({
    required final Map<String, dynamic> data,
    required final String filename,
  }) async {
    // TODO(arenukvern): improve file saving dialog
    /// using "Save File Dialog" / "Document Chooser" in Android
    /// https://gist.github.com/MSVCode/9ccedfa6692f8bc3b82fdc74fad65bc6
    ///
    /// Also there will be a need to write similar thing for iOS
    final path = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select directory to save file',
    );
    if (path == null || path.isEmpty) return false;
    final dir = Directory(path);
    if (!dir.existsSync()) dir.createSync();

    return saveFileData(filePath: '$path/$filename', data: data);
  }

  @override
  Future<bool> saveFileBytes({
    required final List<int> bytes,
    required final String filename,
  }) async {
    final path = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select directory to save file',
    );
    if (path == null || path.isEmpty) return false;
    final dir = Directory(path);
    if (!dir.existsSync()) dir.createSync();
    return saveFileBytesData(filePath: '$path/$filename', bytes: bytes);
  }

  @override
  Future<List<int>?> openFileBytes() async {
    await FilePicker.clearTemporaryFiles();
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return null;
    return result.files.first.readAsBytes();
  }
}

class FileServiceDesktop implements FileServiceI {
  @override
  Future<Map<String, dynamic>> openFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    // User canceled the picker
    if (result == null) return {};

    final dataStr = File(result.files.single.path!).readAsStringSync();
    return jsonDecode(dataStr);
  }

  @override
  Future<bool> saveFile({
    required final Map<String, dynamic> data,
    required final String filename,
  }) async {
    final String? filePath = await FilePicker.saveFile(
      dialogTitle: 'Select directory to save file',
      type: FileType.custom,
      allowedExtensions: ['json'],
      fileName: filename,
      bytes: Uint8List.fromList([]),
    );
    return saveFileData(filePath: filePath, data: data);
  }

  @override
  Future<bool> saveFileBytes({
    required final List<int> bytes,
    required final String filename,
  }) async {
    final filePath = await FilePicker.saveFile(
      dialogTitle: 'Select directory to save file',
      fileName: filename,
      bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
    );
    return saveFileBytesData(filePath: filePath, bytes: bytes);
  }

  @override
  Future<List<int>?> openFileBytes() async {
    final result = await FilePicker.pickFiles();
    // User canceled the picker
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.readAsBytes();
  }
}
