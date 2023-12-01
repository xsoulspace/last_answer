import '../core.dart';

class ScreenPaths {
  ScreenPaths._();
  static const bootstrap = '/';
  static const home = '/home';
  static const intro = '/intro';
  static String idea({required final ProjectModelId ideaId}) =>
      '$home/i/${ideaId.value}';
  static String ideaAnswer({
    required final ProjectModelId ideaId,
    required final ProjectModelId answerId,
  }) =>
      '$home/i/${ideaId.value}/${answerId.value}';
  static String note({required final ProjectModelId noteId}) =>
      '$home/n/${noteId.value}';
}
