import 'package:lastanswer/shared_utils_models/storage_util.dart';

mixin StorageMixin {
  StorageUtil? _storage;
  Future<StorageUtil> get storage async {
    return _storage ??
        await (() async {
          var tempStorage = await StorageUtil.getInstance();
          _storage = tempStorage;
          return tempStorage;
        })();
  }
}
