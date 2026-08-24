import 'dart:io';

import 'package:universal_storage_filesystem/universal_storage_filesystem.dart';
import 'package:universal_storage_git_offline/universal_storage_git_offline.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';

/// IO-platform implementation of backend availability and service builders.

/// Filesystem backend works wherever dart:io works.
bool filesystemSupported() => true;

/// Git offline needs subprocess spawning — impossible on iOS devices
/// (works on the iOS simulator, but keep device correctness first).
bool gitOfflineSupported() => !Platform.isIOS;

/// Builds a filesystem-backed [StorageService] rooted at [path].
Future<StorageService> buildFilesystemService(final String path) async {
  final dir = Directory(path);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final provider = FileSystemStorageProvider();
  await provider.initWithConfig(
    FileSystemConfig(
      filePathConfig: FilePathConfig.create(
        path: dir.path,
        macOSBookmarkData: MacOSBookmark.fromDirectory(dir),
      ),
    ),
  );
  return StorageService(provider);
}

/// Builds a local-git [StorageService] at [path].
Future<StorageService> buildGitOfflineService(final String path) async {
  final provider = OfflineGitStorageProvider(
    commitBatching: const GitCommitBatching(),
  );
  await provider.initWithConfig(
    OfflineGitConfig(
      localPath: path,
      authorName: 'Last Answer',
      authorEmail: 'sync@lastanswer.local',
    ),
  );
  return StorageService(provider);
}
