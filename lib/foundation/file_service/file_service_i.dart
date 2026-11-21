import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:archive/archive.dart' show Archive, ArchiveFile, ZipDecoder, ZipEncoder;
import 'package:lastanswer/foundation/foundation.dart';
import 'package:universal_io/io.dart';

abstract interface class FileServiceI {
  static String get filenameWithTimestamp =>
      'last_answer_${todayDateTime.yyyyMMDD}.json';
  static const filename = 'last_answer.json';
  Future<Map<String, dynamic>> openFile();
  Future<bool> saveFile({
    required final Map<String, dynamic> data,
    required final String filename,
  });

  /// The BYTES lane: one binary backup file (the asset-carrying zip —
  /// `BackupZip`). Absence is honest: an implementation that cannot
  /// carry binaries answers false and the caller falls back to the
  /// JSON-only backup.
  Future<bool> saveFileBytes({
    required final List<int> bytes,
    required final String filename,
  });

  /// The bytes of the picked backup file (zip or json — the caller
  /// sniffs the magic). Null = the user canceled the picker.
  Future<List<int>?> openFileBytes();
}

extension FileServiceIX on FileServiceI {
  bool saveFileData({
    required final String? filePath,
    required final Map<String, dynamic> data,
  }) {
    // User canceled the picker
    if (filePath == null) return false;
    final file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file
      ..createSync()
      ..writeAsStringSync(jsonEncode(data));
    return true;
  }

  bool saveFileBytesData({
    required final String? filePath,
    required final List<int> bytes,
  }) {
    // User canceled the picker
    if (filePath == null) return false;
    final file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file
      ..createSync()
      ..writeAsBytesSync(bytes);
    return true;
  }
}

/// One asset file collected for (or restored from) a backup — the
/// documents-relative [path] keys it inside the backup's `assets/`
/// folder (native-image-assets Wave D1: backup/restore carries the
/// FILES, not base64 in the JSON row).
final class BackupAssetFile {
  const BackupAssetFile({required this.path, required this.bytes});
  final String path;
  final List<int> bytes;
}

/// The zip codec for the asset-carrying backup: `dbSave.json` (the
/// exact legacy `DbSaveModel` JSON) plus `assets/<relative path>` file
/// entries. The zip magic (`PK\x03\x04`) is how a loader tells it apart
/// from the legacy JSON backup — both stay loadable forever.
abstract final class BackupZip {
  static const magic = 'PK\x03\x04';
  static const dbSaveEntryName = 'dbSave.json';
  static const assetsEntryPrefix = 'assets/';

  /// Builds the backup zip bytes, or null when there are no asset
  /// files (the caller writes the legacy JSON instead — byte-identical
  /// behavior for assetless backups).
  static List<int>? encode({
    required final Map<String, dynamic> dbSaveJson,
    required final List<BackupAssetFile> files,
  }) {
    if (files.isEmpty) return null;
    final archive = Archive();
    final dbJsonBytes = utf8.encode(jsonEncode(dbSaveJson));
    archive.addFile(
      ArchiveFile(dbSaveEntryName, dbJsonBytes.length, dbJsonBytes),
    );
    for (final file in files) {
      final bytes = file.bytes is Uint8List
          ? file.bytes as Uint8List
          : Uint8List.fromList(file.bytes);
      archive.addFile(
        ArchiveFile('$assetsEntryPrefix${file.path}', bytes.length, bytes),
      );
    }
    return ZipEncoder().encodeBytes(archive);
  }

  /// Decodes a backup zip; throws [FormatException] named-shape when a
  /// required entry is missing (a corrupt archive refuses, it does not
  /// half-restore).
  static ({Map<String, dynamic> dbSaveJson, List<BackupAssetFile> files})
  decode(final List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final dbEntry = archive.findFile(dbSaveEntryName);
    if (dbEntry == null) {
      throw const FormatException('backup_zip_db_save_entry_missing');
    }
    final dbSaveJson =
        jsonDecode(utf8.decode(dbEntry.content)) as Map<String, dynamic>;
    final files = <BackupAssetFile>[];
    for (final entry in archive.files) {
      final name = entry.name;
      if (!name.startsWith(assetsEntryPrefix)) continue;
      files.add(
        BackupAssetFile(
          path: name.substring(assetsEntryPrefix.length),
          bytes: entry.content,
        ),
      );
    }
    return (dbSaveJson: dbSaveJson, files: files);
  }
}
