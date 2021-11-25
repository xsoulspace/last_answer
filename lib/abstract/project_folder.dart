part of abstract;

typedef ProjectFolderId = String;

@HiveType(typeId: HiveBoxesIds.projectFolder)
class ProjectFolder extends HiveObject
    with EquatableMixin
    implements Loadable, HasId {
  ProjectFolder({
    required final this.id,
    required final this.title,
    final this.projectsService,
    final this.projectsIdsString = '',
    final Map<ProjectId, BasicProject>? projects,
  }) : _projects = projects ?? {};

  ProjectFolder.zero({
    final this.id = '',
    final this.projectsIdsString = '',
    final this.title = '',
    final this.projectsService,
  }) : _projects = {};

  static Future<ProjectFolder> create() async {
    final box =
        await Hive.openBox<ProjectFolder>(HiveBoxesIds.projectFolderKey);

    final folder = ProjectFolder(
      id: createId(),
      // TODO(arenukvern): add translation
      title: 'New',
      projects: {},
    );

    await box.put(folder.id, folder);

    return folder;
  }

  @HiveField(0)
  final ProjectFolderId id;

  @HiveField(1)
  String title;

  /// Used to keep [SerializableProjectId] as json
  @HiveField(2)
  String projectsIdsString;

  Map<ProjectId, BasicProject> _projects;

  /// Runtime projects only. Should be loaded during [onLoad]
  UnmodifiableListView<BasicProject> get projectsList =>
      UnmodifiableListView(_projects.values);
  set projectsList(final Iterable<BasicProject> projects) {
    _projects = Map.fromEntries(projects.map((final e) => MapEntry(e.id, e)));
    _updateIdsString();
  }

  void _updateIdsString() {
    projectsIdsString = jsonEncode(
      _projects.values.map((final e) => e.serializableId.toJson()),
    );
  }

  void addProject(final BasicProject project) {
    _projects[project.id] = project;
    _updateIdsString();
  }

  void removeProject(final BasicProject project) {
    _projects.remove(project.id);
    _updateIdsString();
  }

  bool get isEmpty => _projects.isEmpty;
  bool get isNotEmpty => _projects.isNotEmpty;

  bool get isZero => id.isEmpty;

  /// Optional dependency to load [projects]
  final BasicProjectsService? projectsService;

  @override
  Future<void> onLoad() async {
    if (projectsService != null) {
      projectsList = loadProjectsFromService(
        folder: this,
        service: projectsService!,
      );
    }
  }

  /// Run once when box is uploading to provider
  static Iterable<BasicProject> loadProjectsFromService({
    required final ProjectFolder folder,
    required final BasicProjectsService service,
  }) {
    final Iterable<SerializableProjectId> ids = folder.projectsIdsString.isEmpty
        ? []
        : List.castFrom<dynamic, Map<String, dynamic>>(
            jsonDecode(folder.projectsIdsString),
          ).map(SerializableProjectId.fromJson);

    BasicProject? getProjectById(final SerializableProjectId id) {
      Map<ProjectId, BasicProject?> projects;
      switch (id.type) {
        case ProjectTypes.note:
          projects = service.notes;
          break;
        case ProjectTypes.idea:
          projects = service.ideas;
          break;
        case ProjectTypes.story:
          projects = service.stories;
          break;
        default:
          throw UnimplementedError();
      }
      return projects[id.id];
    }

    final projects = <BasicProject>[];
    for (final id in ids) {
      final project = getProjectById(id);
      if (project == null) continue;
      projects.add(project);
    }
    return projects;
  }

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}
