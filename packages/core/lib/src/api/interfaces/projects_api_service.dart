import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';

abstract interface class ProjectsApiService {
  Future<ProjectModel> upsertProject(final ProjectModel model);
  Future<void> deleteProject(final ProjectModel model);
  @useResult
  Query<ProjectModel> get projectQuery;
  Future<ProjectModel?> getByProjectId(final ProjectModelId id);
}
