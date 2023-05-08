import 'dart:collection';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:core/core.dart';
import 'package:lastanswer/abstract/basic_project.dart';
import 'package:lastanswer/abstract/hive_boxes_ids.dart';
import 'package:lastanswer/abstract/serialazable_project_id.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

part 'project_folder.g.dart';

@HiveType(typeId: HiveBoxesIds.projectFolder)
class ProjectFolder extends RemoteHiveObjectWithId<ProjectFolderModel>
    with EquatableMixin {
  ProjectFolder({
    required this.id,
    required this.title,
    this.projectsIdsString = '',
    final bool? isToDelete,
    final DateTime? updatedAt,
    DateTime? createdAt,
  })  : _projects = createHashSet(),
        isToDelete = isToDelete ?? false,
        createdAt = createdAt ??= dateTimeNowUtc(),
        updatedAt = updatedAt ?? createdAt;

  ProjectFolder.zero({
    this.id = '',
    this.projectsIdsString = '',
    this.title = '',
    this.isToDelete = false,
  })  : _projects = createHashSet(),
        updatedAt = dateTimeNowUtc(),
        createdAt = dateTimeNowUtc();

  static LinkedHashSet<BasicProject> createHashSet() =>
      LinkedHashSet<BasicProject>(
        equals: (final a, final b) => a.hashCode == b.hashCode,
        hashCode: (final a) => a.hashCode,
      );
  static Future<ProjectFolder> fromModel(
          final ProjectFolderModel model) async =>
      create(
        id: model.id,
        title: model.title,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  static Future<ProjectFolder> create({
    final String? id,
    final String? title,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) async {
    final box =
        await Hive.openBox<ProjectFolder>(HiveBoxesIds.projectFolderKey);

    final folder = ProjectFolder(
      id: id ?? createId(),
      title: title ?? 'New',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    await box.put(folder.id, folder);

    return folder;
  }

  @override
  ProjectFolderModel toModel({required final UserModel user}) =>
      ProjectFolderModel(
        id: id,
        title: title,
        createdAt: createdAt,
        updatedAt: updatedAt,
        ownerId: user.id,
      );

  @override
  @HiveField(0)
  final ProjectFolderId id;

  @HiveField(1)
  String title;

  /// Used to keep [SerializableProjectId] as json
  @HiveField(2)
  String projectsIdsString;

  @override
  @HiveField(3)
  bool isToDelete;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  DateTime createdAt;

  LinkedHashSet<BasicProject> _projects;

  /// Runtime projects only. Should be loaded during [onLoad]
  List<BasicProject> get projectsList => _projects.toList();

  /// This function does not add folder to projects.
  ///
  /// To add new project please use [addProject] or [addProjects]
  void setExistedProjects(final Iterable<BasicProject> projects) {
    _projects
      ..clear()
      ..addAll(projects);
    _updateIdsString();
  }

  void reorderProjects({final int oldIndex = 0, final int newIndex = 0}) {
    final list = [...projectsList]..reorder(
        newIndex: newIndex,
        oldIndex: oldIndex,
      );
    setExistedProjects(list);
  }

  /// from new to old
  ///
  /// provide [project] to check its position
  ///
  /// returns false if has no changes
  bool sortProjectsByDate({required final BasicProject project}) {
    if (_projects.first == project) return false;
    setExistedProjects([...projectsList]..sortByDate());

    return true;
  }

  void _updateIdsString() {
    projectsIdsString = jsonEncode(
      _projects.map((final e) => e.serializableId.toJson()).toList(),
    );
    save();
  }

  void addProject(final BasicProject project) {
    final effectiveProjects = [project..folder = this, ..._projects];
    _projects = createHashSet()..addAll(effectiveProjects);
    _updateIdsString();
  }

  void addProjects(final Iterable<BasicProject> projects) {
    for (final project in projects) {
      project.folder = this;
      _projects.add(project);
    }
    _updateIdsString();
  }

  void removeProject(final BasicProject project) {
    _projects.remove(project);
    _updateIdsString();
  }

  bool get isEmpty => _projects.isEmpty;
  bool get isNotEmpty => _projects.isNotEmpty;

  bool get isZero => id.isEmpty;

  /// Run once when box is uploading to provider
  static Iterable<BasicProject> loadProjectsFromService({
    required final ProjectFolder folder,
    required final BasicProjectsDto service,
  }) {
    final Iterable<SerializableProjectId> ids = folder.projectsIdsString.isEmpty
        ? []
        : List.castFrom<dynamic, Map<String, dynamic>>(
            jsonDecode(folder.projectsIdsString),
          ).map(SerializableProjectId.fromJson);

    BasicProject? getProjectById(final SerializableProjectId id) {
      Map<ProjectId, BasicProject?> projects;
      switch (id.type) {
        case ProjectType.note:
          projects = service.notes;
        case ProjectType.idea:
          projects = service.ideas;
        case ProjectType.story:
          throw UnimplementedError();
        // projects = service.stories;
        // break;
        default:
          throw UnimplementedError();
      }

      return projects[id.id];
    }

    final projects = <BasicProject>[];
    for (final id in ids) {
      final project = getProjectById(id);
      if (project == null) continue;
      project.folder = folder;
      projects.add(project);
    }

    return projects;
  }

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;

  @override
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {
    context.read<ProjectFoldersNotifier>().remove(key: key);
    await Future.wait(
      _projects.map(
        (final project) async {
          await project.deleteWithRelatives(context: context);
        },
      ),
    );
    await delete();
  }
}
