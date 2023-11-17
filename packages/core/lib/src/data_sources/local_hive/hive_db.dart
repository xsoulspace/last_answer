import 'package:hive_flutter/hive_flutter.dart';

import '../interfaces/interfaces.dart';
import 'hive_models.dart';

final class ComplexLocalDbHiveImpl implements ComplexLocalDb {
  @override
  Future<void> close() async {
    await Hive.close();
  }

  @override
  Future<void> open() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(IdeaProjectAdapter())
      ..registerAdapter(LocalizedTextAdapter())
      ..registerAdapter(IdeaProjectAnswerAdapter())
      ..registerAdapter(IdeaProjectQuestionAdapter())
      ..registerAdapter(NoteProjectAdapter())
      ..registerAdapter(ProjectFolderAdapter());
  }
}
