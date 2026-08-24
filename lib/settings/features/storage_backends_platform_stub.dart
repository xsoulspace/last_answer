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
