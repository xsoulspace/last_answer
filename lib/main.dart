import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/envs.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Supabase.initialize(
    url: Envs.supabaseUrl,
    anonKey: Envs.supabaseAnon,
    localStorage: const HiveLocalStorage(),
  );

  Hive
    ..registerAdapter(IdeaProjectAdapter())
    ..registerAdapter(LocalizedTextAdapter())
    ..registerAdapter(IdeaProjectAnswerAdapter())
    ..registerAdapter(IdeaProjectQuestionAdapter())
    ..registerAdapter(NoteProjectAdapter())
    ..registerAdapter(ProjectFolderAdapter())
    ..registerAdapter(StoryProjectAdapter());
  runApp(const LastAnswerApp());
}
