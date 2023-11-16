import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_app/pack_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive
    ..registerAdapter(IdeaProjectAdapter())
    ..registerAdapter(LocalizedTextAdapter())
    ..registerAdapter(IdeaProjectAnswerAdapter())
    ..registerAdapter(IdeaProjectQuestionAdapter())
    ..registerAdapter(NoteProjectAdapter())
    ..registerAdapter(ProjectFolderAdapter());
  runApp(const LastAnswerApp());
}
