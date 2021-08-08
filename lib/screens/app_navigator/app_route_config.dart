part of app_navigator;

@immutable
class AppRouteConfig extends Equatable {
  const AppRouteConfig._({
    this.projectId = '',
    this.projectType,
    this.isCreateIdea = false,
    this.isSettings = false,
    this.isUnknown = false,
  });

  factory AppRouteConfig.home() => const AppRouteConfig._();
  factory AppRouteConfig.settings() => const AppRouteConfig._(isSettings: true);
  factory AppRouteConfig.unknown() => const AppRouteConfig._(isUnknown: true);
  factory AppRouteConfig.createIdea() =>
      const AppRouteConfig._(isCreateIdea: true);
  factory AppRouteConfig.idea({required String id}) =>
      AppRouteConfig._(projectId: id, projectType: ProjectTypes.idea);
  factory AppRouteConfig.note({required String id}) =>
      AppRouteConfig._(projectId: id, projectType: ProjectTypes.note);
  factory AppRouteConfig.story({required String id}) =>
      AppRouteConfig._(projectId: id, projectType: ProjectTypes.story);

  final String projectId;
  final ProjectTypes? projectType;
  final bool isSettings;
  final bool isUnknown;
  final bool isCreateIdea;

  bool get isHome =>
      projectId.isEmpty && !isSettings && !isUnknown && !isCreateIdea;
  bool get isIdea => projectId.isNotEmpty && projectType == ProjectTypes.idea;
  bool get isNote => projectId.isNotEmpty && projectType == ProjectTypes.note;
  bool get isStory => projectId.isNotEmpty && projectType == ProjectTypes.story;

  @override
  List<Object?> get props => [
        projectId,
        projectType,
        isSettings,
        isUnknown,
        isCreateIdea,
      ];
  @override
  bool? get stringify => true;
}
