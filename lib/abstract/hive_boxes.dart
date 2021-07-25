import 'package:lastanswer/abstract/themes.dart';

/// all id properties are [HiveBox.typeIds]
class HiveBoxes {
  HiveBoxes._();
  static const int darkModeId = 0;
  static const String darkMode = 'darkMode';
  @Deprecated('')
  static const int projectId = 1;
  @Deprecated('')
  static const String projects = 'projects';

  static const int answerId = 2;
  static const String answers = 'answers';
}

@Deprecated('use [BoxAppTheme] instead')
class BoxDarkMode {
  BoxDarkMode._();
  static const isDark = 'isDark';
}

class BoxAppTheme {
  BoxAppTheme._();
  static const theme = Themes.light;
}

@Deprecated('')
class BoxAnswer {
  BoxAnswer._();
  @Deprecated('')
  static const currentAnswer = 'currentAnswer';
}

@Deprecated('')
class BoxProject {
  BoxProject._();
  @Deprecated('')
  static const currentProject = 'currentProject';
}
