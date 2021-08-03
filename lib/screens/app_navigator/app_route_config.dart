part of app_navigator;

@immutable
class AppRouteConfig {
  const AppRouteConfig._({
    this.id = '',
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
      AppRouteConfig._(id: id, type: ProjectTypes.idea);
  factory AppRouteConfig.note({required String id}) =>
      AppRouteConfig._(id: id, type: ProjectTypes.note);
  factory AppRouteConfig.story({required String id}) =>
      AppRouteConfig._(id: id, type: ProjectTypes.story);

  final String id;
  final ProjectTypes? type;
  final bool isSettings;
  final bool isUnknown;
  final bool isCreateIdea;

  bool get isHome => id.isEmpty;
  bool get isIdea => id.isNotEmpty && type == ProjectTypes.idea;
  bool get isNote => id.isNotEmpty && type == ProjectTypes.note;
  bool get isStory => id.isNotEmpty && type == ProjectTypes.story;
}
