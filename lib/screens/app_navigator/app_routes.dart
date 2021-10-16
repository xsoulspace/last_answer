part of app_navigator;

class AppRoutesName {
  AppRoutesName._();
  static const home = '/';
  static const createIdea = '/idea-c';
  static const ideas = '/ideas';
  static const idea = '$ideas/:id';
  static String getIdeaPath({required final String ideaId}) => '$idea/$ideaId';
  static const notes = '/notes';
  static const note = '$notes/:id';
  static String getNotePath({required final String noteId}) => '$note/$noteId';
  static const stories = '/stories';
  static const story = '$stories/:id';
  static String getStoryPath({required final String storyId}) =>
      '$note/$storyId';
  static const unknown404 = '/404';
  static const settings = '/settings';

  static const values = [
    home,
    createIdea,
    idea,
    ideas,
    note,
    notes,
    story,
    stories,
    unknown404,
    settings,
  ];
}
