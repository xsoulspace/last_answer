part of abstract;

typedef ProjectFolderId = String;

@HiveType(typeId: HiveBoxesIds.projectFolder)
class ProjectFolder extends HiveObject with EquatableMixin implements Loadable {
  ProjectFolder({
    required final this.id,
    required final this.title,
    final this.projectsService,
    final this.projectsIdsString = '',
    final List<BasicProject>? projects,
  }) : projects = projects ?? [];

  static Future<ProjectFolder> create() async {
    final box =
        await Hive.openBox<ProjectFolder>(HiveBoxesIds.projectFolderKey);

    final folder = ProjectFolder(
      id: createId(),
      // TODO(arenukvern): add translation
      title: 'New',
      projects: [],
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

  /// Runtime projects only. Should be loaded during [onLoad]
  final List<BasicProject> projects;

  /// Optional dependency to load [projects]
  final BasicProjectsService? projectsService;

  @override
  Future<void> onLoad() async {
    if (projectsService != null) {
      projects.addAll(
        loadProjectsFromService(
          folder: this,
          service: projectsService!,
        ),
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
