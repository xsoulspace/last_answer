part of abstract;

/// all keys(ids) for [HiveBox.typeIds]
///
/// Important! Do not change order of items and incase of increase
/// just add new item at bottom. In case of replace old value must be marked
/// as [deprecated] and should have name of new value name;
class HiveBoxesIds {
  HiveBoxesIds._();

  /// index 0
  @Deprecated('use [theme] in settings')
  static const darkMode = 0;

  /// index 0
  @Deprecated('use [theme] in settings')
  static const darkModeKey = 'darkMode';

  /// index 1
  @Deprecated('use [ideaProjects]')
  static const projects = 1;

  /// index 1
  @Deprecated('use [ideaProjects]')
  static const projectsKey = 'projects';

  /// index 2
  @Deprecated('use [ideaProjectAnswers]')
  static const answers = 2;

  /// index 2
  @Deprecated('use [ideaProjectAnswers]')
  static const answersKey = 'answers';

  /// index 3
  static const ideaProject = 3;

  /// index 3
  static const ideaProjectKey = 'ideaProject';

  /// index 4
  static const ideaProjectAnswer = 4;

  /// index 4
  static const ideaProjectAnswerKey = 'ideaProjectAnswer';

  /// index 5
  static const ideaProjectsQuestion = 5;

  /// index 5
  static const ideaProjectsQuestionKey = 'ideaProjectsQuestion';

  /// index 6
  static const noteProject = 6;

  /// index 6
  static const noteProjectKey = 'noteProject';

  /// index 7
  static const storyProject = 7;

  /// index 7
  static const storyProjectKey = 'storyProject';
}
