// ignore_for_file: lines_longer_than_80_chars

/// Native-image-assets WAVE D1 — the LA-local asset plane: the FILE is
/// the durable asset (copies land under `note-assets/<noteId>/`), the
/// sniff decides the mime, the containment guard refuses a crafted
/// path, and the collect/restore round-trip keys the backup zip.
library;

import 'dart:convert' show utf8;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_journal/note_asset_store.dart';

Uint8List pngBytes({int width = 64, int height = 48}) {
  final b = BytesBuilder();
  b.add([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  final ihdr = BytesBuilder()
    ..add([...utf8.encode('IHDR')])
    ..add([
      (width >> 24) & 0xff, (width >> 16) & 0xff,
      (width >> 8) & 0xff, width & 0xff,
      (height >> 24) & 0xff, (height >> 16) & 0xff,
      (height >> 8) & 0xff, height & 0xff,
      8, 6, 0, 0, 0,
    ]);
  final chunk = ihdr.toBytes();
  final length = chunk.length - 4;
  b.add([0, 0, (length >> 8) & 0xff, length & 0xff]);
  b.add(chunk);
  b.add([0, 0, 0, 0, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82]);
  return b.toBytes();
}

void main() {
  late Directory documents;
  late NoteAssetStore store;
  const noteId = ProjectModelId('note-1');

  setUp(() async {
    documents = await Directory.systemTemp.createTemp('note_assets_test_');
    store = NoteAssetStore(documentsRoot: documents);
  });
  tearDown(() async {
    if (documents.existsSync()) await documents.delete(recursive: true);
  });

  group('import', () {
    test('a png copies into note-assets/<noteId>/ with sniffed metadata',
        () async {
      final source = File('${documents.path}/incoming.png')
        ..writeAsBytesSync(pngBytes(width: 320, height: 200));
      final asset = await store.importFile(
        sourcePath: source.path,
        noteId: noteId,
      );
      expect(asset.mime, 'image/png');
      expect(asset.width, 320);
      expect(asset.height, 200);
      expect(asset.bytes, source.lengthSync());
      expect(asset.alt, isEmpty);
      expect(asset.path, startsWith('note-assets/note-1/'));
      // The file exists at the resolved path, byte-exact (a COPY — the
      // original never moves).
      final resolved = store.resolve(asset);
      expect(resolved.existsSync(), isTrue);
      expect(resolved.readAsBytesSync(), pngBytes(width: 320, height: 200));
      expect(source.existsSync(), isTrue);
    });

    test('a non-media file refuses by name (the sniff decides)', () async {
      final source = File('${documents.path}/notes.txt')
        ..writeAsStringSync('just text');
      expect(
        () => store.importFile(sourcePath: source.path, noteId: noteId),
        throwsA(isA<NoteAssetException>().having(
          (e) => e.code,
          'code',
          'note_asset_not_media',
        )),
      );
    });

    test('a missing source refuses by name', () {
      expect(
        () => store.importFile(
          sourcePath: '${documents.path}/nope.png',
          noteId: noteId,
        ),
        throwsA(isA<NoteAssetException>().having(
          (e) => e.code,
          'code',
          'note_asset_missing_source',
        )),
      );
    });
  });

  group('the containment guard', () {
    test('a crafted row path resolves OUTSIDE-free (missing, never read)',
        () {
      const crafted = NoteAssetModel(
        id: 'a',
        path: 'note-assets/../secrets.txt',
      );
      expect(store.resolve(crafted).existsSync(), isFalse);
      final escaped = File('${documents.path}/secrets.txt')
        ..writeAsStringSync('private');
      expect(store.resolve(crafted).existsSync(), isFalse);
      expect(escaped.existsSync(), isTrue);
    });

    test('an absolute or backslashed path refuses too', () {
      const absolute = NoteAssetModel(id: 'a', path: '/etc/passwd');
      expect(store.resolve(absolute).existsSync(), isFalse);
      const backslashed = NoteAssetModel(id: 'a', path: r'note-assets\a');
      expect(store.resolve(backslashed).existsSync(), isFalse);
    });
  });

  group('deleteAssets', () {
    test('deletes the files and prunes the empty note dir', () async {
      final a = await store.importBytes(
        bytes: pngBytes(),
        noteId: noteId,
      );
      final b = await store.importBytes(
        bytes: pngBytes(),
        noteId: noteId,
      );
      await store.deleteAssets(noteId: noteId, assets: [a, b]);
      expect(store.exists(a), isFalse);
      expect(store.exists(b), isFalse);
      expect(store.noteDir(noteId).existsSync(), isFalse);
    });
  });

  group('backup collect / restore', () {
    test('collect reads the files; restore writes them back under the '
        'guard', () async {
      final asset = await store.importBytes(bytes: pngBytes(), noteId: noteId);
      final collected = await store.collectForBackup([
        ProjectModelNote(
          id: noteId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          assets: [asset],
        ),
      ]);
      expect(collected, hasLength(1));
      expect(collected.single.path, asset.path);
      expect(collected.single.bytes, pngBytes());

      // Restore into a FRESH documents root (the other device shape).
      final fresh = await Directory.systemTemp.createTemp('note_restore_');
      addTearDown(() => fresh.deleteSync(recursive: true));
      final freshStore = NoteAssetStore(documentsRoot: fresh);
      final restored = await freshStore.restoreFiles(collected);
      expect(restored, 1);
      expect(freshStore.exists(asset), isTrue);
      expect(
        freshStore.resolve(asset).readAsBytesSync(),
        pngBytes(),
      );
    });

    test('a crafted archive path is refused at restore, not written',
        () async {
      final restored = await store.restoreFiles([
        const BackupAssetFile(path: '../escape.bin', bytes: [1, 2, 3]),
      ]);
      expect(restored, 0);
      expect(
        File('${documents.path}/escape.bin').existsSync(),
        isFalse,
      );
    });

    test('a note without assets collects nothing; missing files skip',
        () async {
      const ghost = NoteAssetModel(id: 'g', path: 'note-assets/note-1/ghost.png');
      final collected = await store.collectForBackup([
        ProjectModelNote(
          id: noteId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          assets: [ghost],
        ),
      ]);
      expect(collected, isEmpty);
    });
  });
}
