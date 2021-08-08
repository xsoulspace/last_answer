part of app_navigator;

@immutable
class AppRouteConfig extends Equatable {
  const AppRouteConfig._({
    this.projectId = '',
    this.projectType,
    this.isCreateIdeaPage = false,
    this.isSettingsPage = false,
    this.isUnknownPage = false,
  });

  factory AppRouteConfig.home() => const AppRouteConfig._();
  factory AppRouteConfig.settings() =>
      const AppRouteConfig._(isSettingsPage: true);
  factory AppRouteConfig.unknown() =>
      const AppRouteConfig._(isUnknownPage: true);
  factory AppRouteConfig.createIdea() =>
      const AppRouteConfig._(isCreateIdeaPage: true);
  factory AppRouteConfig.idea({required String id}) =>
      AppRouteConfig._(projectId: id, projectType: ProjectTypes.idea);
  factory AppRouteConfig.note({required String id}) =>
      AppRouteConfig._(projectId: id, projectType: ProjectTypes.note);
  factory AppRouteConfig.story({required String id}) =>
      AppRouteConfig._(projectId: id, projectType: ProjectTypes.story);

  final String projectId;
  final ProjectTypes? projectType;

  // ******************* PAGES ********************

  final bool isSettingsPage;
  final bool isUnknownPage;
  final bool isCreateIdeaPage;

  bool get isHomePage =>
      !isSettingsPage &&
      !isUnknownPage &&
      !isCreateIdeaPage &&
      !isIdeaPage &&
      !isNotePage &&
      !isStoryPage;
  bool get isIdeaPage =>
      projectId.isNotEmpty && projectType == ProjectTypes.idea;
  bool get isNotePage =>
      projectId.isNotEmpty && projectType == ProjectTypes.note;
  bool get isStoryPage =>
      projectId.isNotEmpty && projectType == ProjectTypes.story;

  @override
  List<Object?> get props => [
        projectId,
        projectType,
        isSettingsPage,
        isUnknownPage,
        isCreateIdeaPage,
      ];
  @override
  bool? get stringify => true;
}
