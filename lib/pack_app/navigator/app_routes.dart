part of pack_app;

/// Choose name from [AppRoutesName]
typedef AppRouteName = String;

/// !In case of new routes all routes should be added to values!
class AppRoutesName {
  AppRoutesName._();
  static const home = '/';
  static const createIdea = '/idea-c';
  static const ideas = '/ideas';
  static const idea = '$ideas/:ideaId';
  static String getIdeaPath({required final String ideaId}) => '$ideas/$ideaId';
  static const ideaAnswer = '$ideas/:ideaId/:answerId';
  static String getIdeaAnswerPath({
    required final String ideaId,
    required final String answerId,
  }) =>
      '$ideas/$ideaId/$answerId';

  static const notes = '/notes';
  static const note = '$notes/:noteId';
  static String getNotePath({required final String noteId}) => '$notes/$noteId';
  static const stories = '/stories';
  static const story = '$stories/:storyId';
  static String getStoryPath({required final String storyId}) =>
      '$note/$storyId';
  static const unknown404 = '/404';
  static const settings = '/settings';
  static const generalSettings = '$settings/general';
  static const profile = '$settings/profile';
  static const profileSignIn = '$settings/profile/sign-in';
  static const subscription = '$settings/subscription';
  static const changelog = '$settings/changelog';
  static const appInfo = '/app-info';

  /// !In case of new routes all routes should be added to values!
  static const values = [
    home,
    createIdea,
    idea,
    ideaAnswer,
    ideas,
    note,
    notes,
    story,
    stories,
    unknown404,
    settings,
    appInfo,
    generalSettings,
    profile,
    profileSignIn,
    subscription,
    changelog,
  ];
}
