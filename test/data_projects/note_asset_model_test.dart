// ignore_for_file: lines_longer_than_80_chars

/// Native-image-assets WAVE D1 — the metadata row: additive freezed
/// `assets` list on the note (default-empty so old JSON restores keep
/// working), json round-trip, and the note's own file-name key.
library;

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a note defaults to zero assets (old JSON restores unchanged)',
      () {
    final note = ProjectModelNote(
      id: const ProjectModelId('n1'),
      createdAt: DateTime.utc(2026, 11, 16),
      updatedAt: DateTime.utc(2026, 11, 16),
    );
    expect(note.assets, isEmpty);
  });

  test('the asset row round-trips through the DbSave JSON', () {
    final note = ProjectModelNote(
      id: const ProjectModelId('n1'),
      createdAt: DateTime.utc(2026, 11, 16),
      updatedAt: DateTime.utc(2026, 11, 16),
      note: 'with a picture',
      assets: [
        NoteAssetModel(
          id: 'asset-1',
          path: 'note-assets/n1/asset-1.png',
          alt: 'a lighthouse at dawn',
          width: 1024,
          height: 768,
          bytes: 48213,
          createdAt: DateTime.utc(2026, 11, 16, 12),
        ),
      ],
    );
    // The REAL backup lane writes jsonEncode(dbSave.toJson()) and
    // reads jsonDecode(file) — the round trip goes through the same
    // pass (toJson alone keeps the union objects).
    final json = jsonDecode(
          jsonEncode(DbSaveModel(projects: [note]).toJson()),
        )
        as Map<String, dynamic>;
    final restored =
        DbSaveModel.fromJson(json).projects.single as ProjectModelNote;
    expect(restored.assets, hasLength(1));
    final asset = restored.assets.single;
    expect(asset.id, 'asset-1');
    expect(asset.path, 'note-assets/n1/asset-1.png');
    expect(asset.mime, 'image/png');
    expect(asset.alt, 'a lighthouse at dawn');
    expect(asset.width, 1024);
    expect(asset.height, 768);
    expect(asset.bytes, 48213);
    expect(asset.fileName, 'asset-1.png');
  });

  test('text edits survive the attachments (the copyWith funnel)', () {
    final note = ProjectModelNote(
      id: const ProjectModelId('n1'),
      createdAt: DateTime.utc(2026, 11, 16),
      updatedAt: DateTime.utc(2026, 11, 16),
      assets: [
        const NoteAssetModel(id: 'a', path: 'note-assets/n1/a.png'),
      ],
    );
    final edited = note.copyWith(note: 'typed more');
    expect(edited.assets, hasLength(1));
    expect(edited.assets.single.id, 'a');
  });
}
