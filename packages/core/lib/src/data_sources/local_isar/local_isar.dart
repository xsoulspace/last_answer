import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import '../../../core.dart';

export 'collections/collections.dart';
export 'utils.dart';

final class ComplexLocalDbIsarImpl implements ComplexLocalDb {
  // ignore: avoid_unused_constructor_parameters
  ComplexLocalDbIsarImpl(final BuildContext context);
  Isar? _db;
  Isar get db => _db == null
      ? throw ArgumentError.value('db is not initialzed. Call open first.')
      : _db!;
  @override
  Future<void> open() async {
    if (kIsWeb) return;
    final String dirPath;

    /// doesn't work on web
    if (kIsWeb) {
      dirPath = '/assets/${Envs.isarDbName}';
    } else if (Platform.isIOS) {
      dirPath = (await getLibraryDirectory()).path;
    } else {
      dirPath = (await getApplicationDocumentsDirectory()).path;
    }

    _db ??= Isar.open(
      schemas: [
        ProjectIsarCollectionSchema,
      ],
      directory: dirPath,
      name: Envs.isarDbName,
    );
  }

  IsarCollection<String, ProjectIsarCollection> get projects =>
      db.projectIsarCollections;

  @override
  Future<void> close() async {
    _db?.close();
    _db = null;
  }
}
