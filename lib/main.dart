import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive
    ..registerAdapter(ProjectAdapter())
    ..registerAdapter(AnswerAdapter())
    ..registerAdapter(IdeaProjectAdapter())
    ..registerAdapter(IdeaProjectAdapter())
    ..registerAdapter(LocalizedTextAdapter())
    ..registerAdapter(IdeaProjectAnswerAdapter())
    ..registerAdapter(IdeaProjectQuestionAdapter())
    ..registerAdapter(NoteProjectAdapter())
    ..registerAdapter(StoryProjectAdapter());
  runApp(const AppProvider());
}
