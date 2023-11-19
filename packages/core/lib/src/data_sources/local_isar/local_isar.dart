import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core.dart';

export 'collections/collections.dart';
export 'utils.dart';

final class ComplexLocalDbIsarImpl implements ComplexLocalDb {
  Isar? _db;
  Isar get db => _db == null
      ? throw ArgumentError.value('db is not initialzed. Call open first.')
      : _db!;
  @override
  Future<void> open() async {
    final dir = Platform.isIOS
        ? await getLibraryDirectory()
        : await getApplicationDocumentsDirectory();
    _db ??= await Isar.open(
      [
        ProjectIsarCollectionSchema,
      ],
      directory: dir.path,
      name: Envs.isarDbName,
    );
  }

  IsarCollection<ProjectIsarCollection> get projects =>
      db.projectIsarCollections;

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
