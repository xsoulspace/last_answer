import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lastanswer/shared_utils_models/storage_mixin.dart';

class StorageModel extends ChangeNotifier with StorageMixin {
  // Private constructor
  StorageModel._create();

  /// Public factory
  static Future<StorageModel> create() async {
    // Call the private constructor
    final storageModel = StorageModel._create();

    // Return the fully initialized object
    return storageModel;
  }

  Future<void> save<T>({required String key, required Object value}) async {
    (await storage).putString(key, jsonEncode(value));
  }

  Future<T?> load<T>(String key) async {
    final value = (await storage).getString(key);
    if (value == '') return null;
    return jsonDecode(value);
  }
}
