import 'package:flutter/cupertino.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/screens/app/app.dart';
import 'package:universal_io/io.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux) {
    await Window.initialize();
    await Window.setEffect(
      effect: WindowEffect.acrylic,
      color: const Color(0xCC222222),
    );
  }
  await Hive.initFlutter();
  Hive
    ..registerAdapter(IdeaProjectAdapter())
    ..registerAdapter(LocalizedTextAdapter())
    ..registerAdapter(IdeaProjectAnswerAdapter())
    ..registerAdapter(IdeaProjectQuestionAdapter())
    ..registerAdapter(NoteProjectAdapter())
    ..registerAdapter(StoryProjectAdapter());
  runApp(const AppProvider());
}
