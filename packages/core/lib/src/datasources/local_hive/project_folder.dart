part of 'hive_models.dart';

typedef ProjectFolderId = String;

@Deprecated('')
@HiveType(typeId: HiveBoxesIds.projectFolder)
class ProjectFolder extends HiveObject with EquatableMixin, HasId {
  @Deprecated('')
  ProjectFolder({
    required this.id,
    required this.title,
    this.projectsIdsString = '',
  }) : _projects = createHashSet();

  @Deprecated('')
  ProjectFolder.zero({
    this.id = '',
    this.projectsIdsString = '',
    this.title = '',
  }) : _projects = createHashSet();

  static LinkedHashSet<BasicProject> createHashSet() =>
      LinkedHashSet<BasicProject>(
        equals: (final a, final b) => a.hashCode == b.hashCode,
        hashCode: (final a) => a.hashCode,
      );

  static Future<ProjectFolder> create() async {
    final box =
        await Hive.openBox<ProjectFolder>(HiveBoxesIds.projectFolderKey);

    final folder = ProjectFolder(
      id: createId(),
      title: 'New',
    );

    await box.put(folder.id, folder);

    return folder;
  }

  @override
  @HiveField(0)
  final ProjectFolderId id;

  @HiveField(1)
  String title;

  /// Used to keep [SerializableProjectId] as json
  @HiveField(2)
  String projectsIdsString;

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
    unawaited(save());
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
    required final NoteProjectsState notes,
    required final IdeaProjectsState ideas,
  }) {
    final Iterable<SerializableProjectId> ids = folder.projectsIdsString.isEmpty
        ? []
        : List.castFrom<dynamic, Map<String, dynamic>>(
            jsonDecode(folder.projectsIdsString),
          ).map(SerializableProjectId.fromJson);

    BasicProject? getProjectById(final SerializableProjectId id) {
      final Map<ProjectId, BasicProject?> projects = switch (id.type) {
        ProjectTypes.note => notes.state,
        ProjectTypes.idea => ideas.state,
      };

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
}

extension BasicProjectListExtension on List<BasicProject> {
  void sortByDate() => sort(
        (final a, final b) => b.updated.compareTo(a.updated),
      );
}
