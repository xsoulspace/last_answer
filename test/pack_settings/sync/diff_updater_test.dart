import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/note_updater.dart';
import 'package:lastanswer/utils/utils.dart';

void main() {
  group('DiffUpdater', () {
    test('one note project can be updated with note model', () {
      final id = createId();
      final createdAt = DateTime.now().subtract(const Duration(days: 1));
      final updatedAt = DateTime.now();
      final noteProject = NoteProject(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
        note: 'hi world',
      );
      final noteModel = BasicProjectModel.noteProjectModel(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isCompleted: false,
        projectType: ProjectType.note,
        userId: '',
        folderId: '',
        charactersLimit: null,
        note: 'note',
      );
      if (noteModel is! NoteProjectModel) return;

      final existedProjects = [noteProject];
      final serverProjects = [noteModel];

      final updated = NoteUpdater.of(
        list: existedProjects,
      ).updateByOther(serverProjects);

      expect(updated.length, equals(1));
      expect(updated.first.note, equals(noteModel.note));
    });
    test('several note projects can be updated with note models', () {});
    test('one idea project answer can be updated by idea answer model', () {
      final id = createId();
      final createdAt = DateTime.now().subtract(const Duration(days: 1));
      final updatedAt = DateTime.now();
      final question = IdeaProjectQuestion(
        id: 'q',
        title: const LocalizedText(en: '', ru: 'Why?'),
      );
      final ideaProjectAnswer = IdeaProjectAnswer(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
        text: 'Because of the world',
        question: question,
      );
      final ideaProjectAnswerModel = IdeaProjectAnswerModel(
        id: id,
        text: 'Because of the world - and future',
        questionId: question.id,
        projectId: 'p',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      final existedProjects = [ideaProjectAnswer];
      final serverProjects = [ideaProjectAnswerModel];

      final updated = NoteUpdater.of(
        list: existedProjects,
      ).updateByOther(serverProjects);

      expect(updated.length, equals(2));
      expect(updated.first.text, equals(ideaProjectAnswerModel.text));
    });
    test(
      'several idea project answers can be updated by idea answer models',
      () {},
    );
  });
}
