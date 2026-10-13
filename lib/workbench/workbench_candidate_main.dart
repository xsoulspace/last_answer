/// Isolated native acceptance shell using the production workbench and storage.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/workbench/workbench_screen.dart';
import 'package:provider/provider.dart';
import 'package:universal_storage_filesystem/universal_storage_filesystem.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService(FileSystemStorageProvider());
  final directory = Directory(
    '${Platform.environment['HOME']}/Library/Application Support/LastAnswerWorkbenchCandidate',
  );
  await directory.create(recursive: true);
  await storage.initializeWithConfig(
    FileSystemConfig(filePathConfig: FilePathConfig({'path': directory.path})),
  );
  runApp(
    Provider<DocumentRepository>.value(
      value: StorageDocumentRepository(service: storage),
      child: MaterialApp(
        title: 'Last Answer Workbench Candidate',
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          scaffoldBackgroundColor: const Color(0xfffaf9f4),
        ),
        home: const WorkbenchScreen(),
      ),
    ),
  );
}
