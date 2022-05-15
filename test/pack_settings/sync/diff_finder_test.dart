import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_settings/sync/diff_finder.dart';
import 'package:lastanswer/utils/utils.dart';

void main() {
  group('DiffFinder', () {
    test('note project vs note model', () {
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
      final existedProjects = [noteProject];
      final serverProjects = [noteModel];

      final diffs = DiffFinder.of(
        list: existedProjects,
        otherList: serverProjects,
        policy: DiffConflictPolicy.replaceByActiveDevice,
      ).changes;

      expect(diffs.length, equals(1));
      expect(diffs.first, StringDiff());
    });
    test('idea project answer vs idea answer model', () {
      final id = createId();
      final createdAt = DateTime.now().subtract(const Duration(days: 1));
      final updatedAt = DateTime.now();
      final noteProject = IdeaProjectAnswer(
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
      final existedProjects = [noteProject];
      final serverProjects = [noteModel];

      final diffs = DiffFinder.of(
        list: existedProjects,
        otherList: serverProjects,
        policy: DiffConflictPolicy.replaceByActiveDevice,
      ).changes;

      expect(diffs.length, equals(1));
      expect(diffs.first, StringDiff());
    });
  });
}
