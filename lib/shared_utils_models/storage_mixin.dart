import 'package:lastanswer/shared_utils_models/storage_util.dart';

mixin StorageMixin {
  StorageUtil? _storage;
  Future<StorageUtil> get storage async =>
      _storage ??= await StorageUtil.getInstance();
}
