import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_models/shared_models.dart';
import 'package:universal_io/io.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart'
    show assetMimeFromPath, sniffAssetMedia;

/// The LA-local asset plane for note images (native-image-assets Wave
/// D, LA ADR 0029). The FILE is the durable asset — a sibling file
/// under the app documents dir keyed by note id
/// (`note-assets/<noteId>/<assetId>.<ext>`) — and the note row carries
/// only the compact metadata (`NoteAssetModel`), mirroring the
/// harness's pixels-never-enter-the-record law (ADR 0142).
///
/// Import COPIES (the original never mutates); the sniffed mime is the
/// truth, never the extension; every write goes through the
/// `note-assets/` containment guard, so a hand-edited backup row or a
/// crafted zip cannot escape the documents root.
final class NoteAssetStore {
  NoteAssetStore({required this._documentsRoot});

  static NoteAssetStore? _instance;

  /// The process singleton over the app documents dir. Web has no
  /// local file plane — the attach flows refuse honestly there.
  static Future<NoteAssetStore> instance() async {
    final existing = _instance;
    if (existing != null) return existing;
    if (kIsWeb) {
      throw const NoteAssetException('note_asset_store_unsupported_on_web');
    }
    final dir = await getApplicationDocumentsDirectory();
    return _instance ??= NoteAssetStore(documentsRoot: dir);
  }

  /// Test seam: binds a disposable root; never set from product code.
  // ignore: avoid_setters_without_getters -- a one-way test seam by design
  static set debugInstance(final NoteAssetStore store) => _instance = store;

  final Directory _documentsRoot;

  /// The documents-relative root every note asset lives under — also
  /// the backup zip's folder and the restore containment guard.
  static const relativeRoot = 'note-assets';

  static const _extByMime = <String, String>{
    'image/png': 'png',
    'image/jpeg': 'jpg',
    'image/webp': 'webp',
    'image/gif': 'gif',
    'image/svg+xml': 'svg',
  };

  Directory noteDir(final ProjectModelId noteId) => Directory(
    '${_documentsRoot.path}/$relativeRoot/${noteId.value}',
  );

  /// The absolute file for a metadata row, resolved under the documents
  /// root. A row whose path escaped the containment guard (corrupt or
  /// hand-edited) resolves to a MISSING file — the honest placeholder,
  /// never a read outside the root.
  File resolve(final NoteAssetModel asset) {
    if (!_isContained(asset.path)) {
      return File('${_documentsRoot.path}/__contained_refused__');
    }
    return File('${_documentsRoot.path}/${asset.path}');
  }

  bool exists(final NoteAssetModel asset) => resolve(asset).existsSync();

  /// Imports one media file by COPYING it into the note's asset dir.
  /// The sniff decides the mime (and whether it is media at all — a
  /// non-media file refuses by name, like the harness `ingest` verb).
  Future<NoteAssetModel> importFile({
    required final String sourcePath,
    required final ProjectModelId noteId,
    final String alt = '',
  }) {
    final file = File(sourcePath);
    if (!file.existsSync()) {
      throw const NoteAssetException('note_asset_missing_source');
    }
    return importBytes(
      bytes: file.readAsBytesSync(),
      noteId: noteId,
      alt: alt,
      nameHint: file.uri.pathSegments.last,
    );
  }

  /// Imports raw bytes (a generated image, a pasted one). The sniff is
  /// the truth; [nameHint] only picks the extension when the mime is
  /// not one of the known image types.
  Future<NoteAssetModel> importBytes({
    required final List<int> bytes,
    required final ProjectModelId noteId,
    final String alt = '',
    final String? nameHint,
  }) async {
    final asBytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final meta = sniffAssetMedia(asBytes, byteLength: asBytes.length);
    if (meta == null) {
      throw const NoteAssetException('note_asset_not_media');
    }
    final assetId = createId();
    final ext =
        _extByMime[meta.mimeType] ??
        (nameHint != null && nameHint.contains('.')
            ? nameHint.split('.').last.toLowerCase()
            : 'img');
    final dir = noteDir(noteId);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('${dir.path}/$assetId.$ext');
    await file.writeAsBytes(asBytes, flush: true);
    return NoteAssetModel(
      id: assetId,
      path: '$relativeRoot/${noteId.value}/$assetId.$ext',
      mime: meta.mimeType,
      alt: alt,
      width: meta.width ?? 0,
      height: meta.height ?? 0,
      bytes: meta.byteLength,
      createdAt: DateTime.now(),
    );
  }

  /// Deletes the files of [assets] and prunes the note's dir when it
  /// ends empty. Missing files are not errors.
  Future<void> deleteAssets({
    required final ProjectModelId noteId,
    required final List<NoteAssetModel> assets,
  }) async {
    for (final asset in assets) {
      final file = resolve(asset);
      if (file.existsSync()) await file.delete();
    }
    final dir = noteDir(noteId);
    if (dir.existsSync() && dir.listSync().isEmpty) await dir.delete();
  }

  /// Reads every note asset file for a backup. Missing files are
  /// skipped (the restore names them honestly); rows whose path fails
  /// the containment guard are skipped too.
  Future<List<BackupAssetFile>> collectForBackup(
    final List<ProjectModel> projects,
  ) async {
    final files = <BackupAssetFile>[];
    for (final project in projects) {
      final note = project.mapOrNull(
        note: (final note) => note,
        idea: (_) => null,
        changelog: (_) => null,
        doc: (_) => null,
      );
      if (note == null) continue;
      for (final asset in note.assets) {
        if (!_isContained(asset.path)) continue;
        final file = resolve(asset);
        if (!file.existsSync()) continue;
        files.add(
          BackupAssetFile(path: asset.path, bytes: file.readAsBytesSync()),
        );
      }
    }
    return files;
  }

  /// Writes restored backup files under the documents root. Every path
  /// must stay inside [relativeRoot] — the containment guard refuses a
  /// crafted archive instead of writing outside.
  Future<int> restoreFiles(final List<BackupAssetFile> files) async {
    var restored = 0;
    for (final entry in files) {
      if (!_isContained(entry.path)) continue;
      final file = File('${_documentsRoot.path}/${entry.path}');
      await file.create(recursive: true);
      await file.writeAsBytes(entry.bytes, flush: true);
      restored++;
    }
    return restored;
  }

  /// The containment guard: documents-relative, inside `note-assets/`,
  /// no `..` segments, no absolute form.
  bool _isContained(final String path) {
    if (path.isEmpty) return false;
    if (path.startsWith('/') || path.contains(r'\')) return false;
    if (!path.startsWith('$relativeRoot/')) return false;
    final segments = path.split('/');
    return segments.every((final s) => s.isNotEmpty && s != '.' && s != '..');
  }

  /// The documents-relative path for a not-yet-imported candidate —
  /// used by flows that write the file first (a generated image) and
  /// then record the row.
  String pathFor({
    required final ProjectModelId noteId,
    required final String fileName,
  }) => '$relativeRoot/${noteId.value}/$fileName';

  /// The mime an asset FILE should carry, from its name — used by
  /// restore flows that validate before write.
  String? mimeFromName(final String name) => assetMimeFromPath(name);
}

/// One asset file collected for (or restored from) a backup zip rides
/// core's `BackupAssetFile` (the documents-relative path keys it inside
/// the archive's `assets/` folder) — one data shape, one owner.

/// A named note-asset failure: `note_asset_missing_source` (the picked
/// file vanished before the copy) · `note_asset_not_media` (the bytes
/// are not a media format — the sniff decides, never the extension).
final class NoteAssetException implements Exception {
  const NoteAssetException(this.code);
  final String code;
  @override
  String toString() => code;
}
