import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

import '../../../core.dart';

final class ComplexLocalDbSembastWebImpl implements ComplexLocalDb {
  StoreRef<int, Map<String, Object?>> get db => _store == null
      ? throw ArgumentError.value('db is not initialzed. Call open first.')
      : _store!;
  StoreRef<int, Map<String, Object?>>? _store;
  Database? _db;
  @override
  Future<void> open() async {
    // Declare our store (records are mapd, ids are ints)
    _store = intMapStoreFactory.store();
    final factory = databaseFactoryWeb;

    // Open the database
    _db = await factory.openDatabase(
      Envs.sembastWebDbName,
      version: Envs.sembastWebDbVersion,
    );
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
