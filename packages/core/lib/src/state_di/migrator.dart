import 'package:flutter/foundation.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:path_provider/path_provider.dart';

Future<void> migrate() async {
  final String dirPath;
  if (kIsWeb) {
    dirPath = '/assets/${Envs.isarDbName}';
  } else if (Platform.isIOS) {
    dirPath = (await getLibraryDirectory()).path;
  } else {
    dirPath = (await getApplicationDocumentsDirectory()).path;
  }

  // List all files in the directory
  final files = Directory(dirPath).listSync();
  final isarFiles = files
      .where((final file) => file.path.endsWith('.isar'))
      .toList();

  if (isarFiles.isEmpty) {
    print('No Isar files found.');
    return;
  }
  final list = <String>[];
  print('Found Isar files:');
  for (final file in isarFiles) {
    print(file.path);
    final exists = File(file.path).existsSync();
    print('Exists: $exists');
    final content = File(file.path).readAsBytesSync();
    list.add(content.toString());
  }
  print('List length: ${list.length}');
}
