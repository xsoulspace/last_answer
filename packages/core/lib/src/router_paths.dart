class AppPaths {
  AppPaths._();
  static const bootstrap = '/';
  static const home = '/home';
  static const intro = '/intro';
  static const createIdea = '/i/create';
  static const ideas = '/i';
  static const idea = '$ideas/:ideaId';
  static String getIdeaPath({required final String ideaId}) => '$ideas/$ideaId';
  static const ideaAnswer = '$ideas/:ideaId/:answerId';
  static String getIdeaAnswerPath({
    required final String ideaId,
    required final String answerId,
  }) =>
      '$ideas/$ideaId/$answerId';
  static const notes = '/n';
  static const note = '$notes/:noteId';
  static String getNotePath({required final String noteId}) => '$notes/$noteId';
  static const settings = '/settings';
  static const generalSettings = '$settings/general';
  static const profile = '$settings/profile';
  static const subscription = '$settings/subscription';
  static const changelog = '$settings/changelog';
  static const appInfo = '/info';
}
