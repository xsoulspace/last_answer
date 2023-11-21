import '../core.dart';

class ScreenPaths {
  ScreenPaths._();
  static const bootstrap = '/';
  static const home = '/home';
  static const intro = '/intro';
  static const createIdea = '$home/i/create';
  static String idea({required final ProjectModelId ideaId}) =>
      '$home/i/${ideaId.value}';
  static String ideaAnswer({
    required final ProjectModelId ideaId,
    required final ProjectModelId answerId,
  }) =>
      '$home/i/${ideaId.value}/${answerId.value}';
  static String note({required final ProjectModelId noteId}) =>
      '$home/n/${noteId.value}';
  static const settings = '/settings';
  static const generalSettings = '$settings/general';
  static const profile = '$settings/profile';
  static const subscription = '$settings/subscription';
  static const changelog = '$settings/changelog';
  static const appInfo = '/info';
}
