// ignore_for_file: lines_longer_than_80_chars

/// Native-image-assets WAVE D1 — the asset-carrying backup: the zip
/// (`PK` magic) carries `dbSave.json` + `assets/<relative path>` file
/// entries; an assetless backup answers null so the legacy JSON path
/// stays byte-identical; a corrupt archive refuses by name instead of
/// half-restoring; the legacy JSON remains loadable forever.
library;

import 'dart:convert';

import 'package:archive/archive.dart' show Archive, ArchiveFile, ZipEncoder;
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/common_imports.dart';

void main() {
  Map<String, dynamic> dbSaveJson() => DbSaveModel(
    projects: [
      ProjectModelNote(
        id: const ProjectModelId('n1'),
        createdAt: DateTime.utc(2026, 11, 16),
        updatedAt: DateTime.utc(2026, 11, 16),
        note: 'hello',
      ),
    ],
  ).toJson();

  test('an assetless backup encodes to null (the JSON path holds)', () {
    expect(
      BackupZip.encode(dbSaveJson: dbSaveJson(), files: const []),
      isNull,
    );
  });

  test('the zip carries dbSave.json + asset entries and round-trips', () {
    final bytes = BackupZip.encode(
      dbSaveJson: dbSaveJson(),
      files: const [
        BackupAssetFile(
          path: 'note-assets/n1/asset-1.png',
          bytes: [0x89, 0x50, 0x4e, 0x47],
        ),
        BackupAssetFile(
          path: 'note-assets/n1/asset-2.jpg',
          bytes: [1, 2, 3, 4, 5],
        ),
      ],
    );
    expect(bytes, isNotNull);
    // The zip magic is the loader's discriminator.
    expect(bytes!.sublist(0, 4), utf8.encode('PK\x03\x04'));

    final bundle = BackupZip.decode(bytes);
    expect(bundle.dbSaveJson['projects'], hasLength(1));
    expect(bundle.files, hasLength(2));
    expect(
      bundle.files.first.path,
      'note-assets/n1/asset-1.png',
    );
    expect(bundle.files.first.bytes, [0x89, 0x50, 0x4e, 0x47]);
    expect(bundle.files.last.bytes, [1, 2, 3, 4, 5]);
  });

  test('the round trip preserves the note rows byte-identically', () {
    // The REAL backup serializes through jsonEncode (the union objects
    // ride along), so the round-trip comparison goes through the same
    // pass — what lands in dbSave.json is what comes back.
    final original = jsonDecode(jsonEncode(dbSaveJson()))
        as Map<String, dynamic>;
    final bytes = BackupZip.encode(
      dbSaveJson: original,
      files: const [
        BackupAssetFile(path: 'note-assets/n1/a.png', bytes: [9]),
      ],
    )!;
    final bundle = BackupZip.decode(bytes);
    expect(bundle.dbSaveJson, original);
    final restored = DbSaveModel.fromJson(bundle.dbSaveJson);
    final note = restored.projects.single as ProjectModelNote;
    expect(note.note, 'hello');
    // The restored row carries the assets list shape (empty here —
    // the JSON backup never had them).
    expect(note.assets, isEmpty);
  });

  test('a zip without dbSave.json refuses by name (never half-restores)',
      () {
    // Crafted through the same codec primitives: assets only, no db
    // entry — the restore must refuse instead of silently restoring
    // rows while the assets silently vanish.
    final archive = Archive()
      ..addFile(ArchiveFile('only-assets.png', 1, [1]));
    final zipBytes = ZipEncoder().encodeBytes(archive);
    expect(zipBytes.sublist(0, 4), utf8.encode('PK\x03\x04'));
    expect(
      () => BackupZip.decode(zipBytes),
      throwsA(isA<FormatException>().having(
        (e) => e.message,
        'message',
        'backup_zip_db_save_entry_missing',
      )),
    );
  });
}
