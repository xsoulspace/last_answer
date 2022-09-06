import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/envs.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_io/io.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && !Platform.isIOS && !Platform.isAndroid) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
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
  runApp(const AppScaffold());
}
