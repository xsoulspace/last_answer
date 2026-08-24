import 'package:universal_storage_interface/universal_storage_interface.dart';

/// Web stub: browsers have no dart:io filesystem or process spawning.
///
/// (Browser File System Access API support can be added later as a
/// dedicated web provider.)

/// No folder access without the File System Access API picker.
bool filesystemSupported() => false;

/// Cannot spawn `git` in a browser.
bool gitOfflineSupported() => false;

/// Unsupported on web; callers check availability before calling.
Future<StorageService> buildFilesystemService(final String path) async =>
    throw UnsupportedError('Filesystem backend is not supported on web');

/// Unsupported on web; callers check availability before calling.
Future<StorageService> buildGitOfflineService(final String path) async =>
    throw UnsupportedError('Git offline backend is not supported on web');

Future<StorageService> Function({
  required String storePath,
  required Uri relayEndpoint,
  required String peerId,
})
get buildMeshService => _buildMeshService;

Future<StorageService> _buildMeshService({
  required final String storePath,
  required final Uri relayEndpoint,
  required final String peerId,
}) async => throw UnsupportedError('Mesh backend is not supported on web');

/// No default path without a filesystem.
Future<String> defaultFilesystemPath() async => '';
