part of app_navigator;

@immutable
class AppRouteConfig extends Equatable {
  const AppRouteConfig._({
    this.projectId = '',
    this.isCreateIdea = false,
    this.isSettings = false,
    this.isUnknown = false,
    this.type,
  });

  factory AppRouteConfig.home() => const AppRouteConfig._();
  factory AppRouteConfig.settings() => const AppRouteConfig._(isSettings: true);
  factory AppRouteConfig.unknown() => const AppRouteConfig._(isUnknown: true);
  factory AppRouteConfig.createIdea() =>
      const AppRouteConfig._(isCreateIdea: true);
  factory AppRouteConfig.idea({required String id}) =>
      AppRouteConfig._(projectId: id, type: ProjectTypes.idea);
  factory AppRouteConfig.note({required String id}) =>
      AppRouteConfig._(projectId: id, type: ProjectTypes.note);
  factory AppRouteConfig.story({required String id}) =>
      AppRouteConfig._(projectId: id, type: ProjectTypes.story);

  final String projectId;
  final ProjectTypes? type;
  final bool isSettings;
  final bool isUnknown;
  final bool isCreateIdea;

  bool get isHome =>
      projectId.isEmpty && !isSettings && !isUnknown && !isCreateIdea;
  bool get isIdea => projectId.isNotEmpty && type == ProjectTypes.idea;
  bool get isNote => projectId.isNotEmpty && type == ProjectTypes.note;
  bool get isStory => projectId.isNotEmpty && type == ProjectTypes.story;

  @override
  List<Object?> get props => [
        projectId,
        type,
        isSettings,
        isUnknown,
        isCreateIdea,
      ];
  @override
  bool? get stringify => true;
}
