import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:last_answer/models/answers_model.dart';
import 'package:last_answer/models/projects_model.dart';
import 'package:last_answer/models/questions_model.dart';
import 'package:last_answer/shared_utils_models/storage_mixin.dart';

class StorageModel extends ChangeNotifier with StorageMixin {
  ProjectsModel _projectsModel;
  AnswersModel _answersModel;

  // Private constructor
  StorageModel._create(this._projectsModel, this._answersModel);

  /// Public factory
  static Future<StorageModel> create(
      {required ProjectsModel projectsModel,
      required AnswersModel answersModel}) async {
    // Call the private constructor
    var storageModel = StorageModel._create(projectsModel, answersModel);

    await storageModel.loadAnswersModel();
    await storageModel.loadProjectsModel();
    // Return the fully initialized object
    return storageModel;
  }

  Future<void> save<T>({required String key, required Object value}) async {
    (await storage).putString(key, jsonEncode(value));
  }

  Future<T?> load<T>(String key) async {
    var value = (await storage).getString(key);
    if (value == '') return null;
    return jsonDecode(value);
  }

  Future<void> saveAnswersModel() async {
    await save(
        key: AnswersModelConsts.storagename, value: _answersModel.toJson());
  }

  Future<void> loadAnswersModel() async {
    var modelStr = await load(AnswersModelConsts.storagename);
    if (modelStr == null) return;
    var model = AnswersModel.fromJson(modelStr);
    _answersModel
      ..reloadPlayers(playersByPlayerIdMap: model.playersByPlayerIdMap)
      ..currentPlayer = model.currentPlayer
      ..notifyListeners();
    notifyListeners();
  }

  Future<void> loadProjectsModel() async {
    var modelStr = await load(LocalDictionaryModelConsts.storagename);
    if (modelStr == null) return;
    var model = LocalDictionaryModel.fromJson(modelStr);
    _projectsModel
      ..reloadState(words: model.words)
      ..notifyListeners();
    notifyListeners();
  }

  Future<void> saveProjectsModel() async {
    await save(
        key: ProjectsModelConsts.storagename, value: _projectsModel.toJson());
  }
}
