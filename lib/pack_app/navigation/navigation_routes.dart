import 'package:lastanswer/pack_core/pack_core.dart';

/// !If you want to add new route, please add the route to the [routes]
class NavigationRoutes {
  NavigationRoutes._();
  static const home = '/';
  static const createIdea = '/idea-c';
  static const ideas = '/ideas';
  static const idea = '$ideas/:ideaId';
  static String getIdeaPath({required final ProjectId ideaId}) =>
      '$ideas/$ideaId';
  static const ideaAnswer = '$ideas/:ideaId/:answerId';
  static String getIdeaAnswerPath({
    required final ProjectId ideaId,
    required final String answerId,
  }) =>
      '$ideas/$ideaId/$answerId';

  static const notes = '/notes';
  static const note = '$notes/:noteId';
  static String getNotePath({required final ProjectId noteId}) =>
      '$notes/$noteId';
  static const stories = '/stories';
  static const story = '$stories/:storyId';
  static String getStoryPath({required final ProjectId storyId}) =>
      '$note/$storyId';
  static const unknown404 = '/404';
  static const settings = '/settings';
  static const generalSettings = '$settings/general';
  static const profile = '$settings/profile';
  static const signIn = '$settings/profile/sign-in';
  static const signUp = '$settings/profile/sign-up';
  static const subscription = '$settings/subscription';
  static const changelog = '$settings/changelog';
  static const appInfo = '/app-info';

  static const routes = [
    home,
    createIdea,
    ideas,
    idea,
    ideaAnswer,
    notes,
    note,
    stories,
    story,
    unknown404,
    settings,
    generalSettings,
    profile,
    signUp,
    subscription,
    changelog,
    appInfo,
  ];
}
