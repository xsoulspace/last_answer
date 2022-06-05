import 'package:equatable/equatable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeletableTestItem extends RemoteHiveObjectWithId<TestItem>
    with EquatableMixin {
  DeletableTestItem({
    required this.id,
    this.isToDelete = false,
  });
  @override
  final String id;

  @override
  bool isToDelete;

  @override
  List<Object?> get props => [id];

  @override
  Future<void> deleteWithRelatives({required final BuildContext context}) {
    // TODO: implement deleteWithRelatives
    throw UnimplementedError();
  }

  @override
  TestItem toModel({required final UserModel user}) {
    // TODO: implement toModel
    throw UnimplementedError();
  }
}

class TestItem with EquatableMixin implements HasId {
  TestItem(this.id);
  @override
  final String id;
  @override
  List<Object?> get props => [id];
}

class TestItemApi extends AbstractApi<TestItem> {
  @override
  SupabaseClient get client => throw UnimplementedError();

  @override
  Future<TestItem?> delete(final TestItem model) {
    throw UnimplementedError();
  }

  @override
  TestItem Function(Map<String, dynamic> json) get fromJson =>
      throw UnimplementedError();

  @override
  Future<Iterable<TestItem>> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<TestItem?> getById(final String id) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> Function(TestItem model) get modelToJson =>
      throw UnimplementedError();

  @override
  RealtimeSubscription subscribeToDeletes(
    final ValueChanged<TestItem> onDelete,
  ) {
    throw UnimplementedError();
  }

  @override
  RealtimeSubscription subscribeToNew(final ValueChanged<TestItem> onNew) {
    throw UnimplementedError();
  }

  @override
  RealtimeSubscription subscribeToUpdates(
    final ValueChanged<TestItem> onUpdate,
  ) {
    throw UnimplementedError();
  }

  @override
  String get tableName => throw UnimplementedError();

  @override
  Future<TestItem> upsert(final TestItem model) {
    throw UnimplementedError();
  }

  @override
  Future<Iterable<TestItem>> upsertElements(final Iterable<TestItem> models) {
    throw UnimplementedError();
  }
}

void main() {
  group('InstanceUpdater', () {
    test('compareConsistency - original creates,deletes, other creates,remains',
        () {
      final supabaseClient = SupabaseClient('', '');
      final originalListToCreate = List.generate(
        5,
        (final index) => DeletableTestItem(
          id: '${index + 100}',
        ),
      );
      final originalList = List.generate(
            5,
            (final index) => DeletableTestItem(
              id: '$index',
              isToDelete: index.isEven,
            ),
          ) +
          originalListToCreate;
      final instancesToDelete = [
        TestItem('0'),
        TestItem('2'),
        TestItem('4'),
      ];

      final otherList = List.generate(20, (final index) => TestItem('$index'));
      final diff = InstanceUpdater<DeletableTestItem, TestItem,
          MapState<DeletableTestItem>>(
        clientSyncService: ClientInstancesSyncServiceI(),
      ).compareConsistency(otherList: otherList, list: originalList);
      final otherUpdates = diff.otherUpdates;
      final originalUpdates = diff.originalUpdates;

      /// ********************************************
      /// *      OTHER DELETE START
      /// ********************************************
      expect(otherUpdates.toDelete.length, equals(instancesToDelete.length));
      expect(otherUpdates.toDelete.toList(), equals(instancesToDelete));

      /// ********************************************
      /// *      OTHER CREATE START
      /// ********************************************
      expect(
        otherUpdates.toCreateFromOther.length,
        equals(originalListToCreate.length),
      );
      expect(
        otherUpdates.toCreateFromOther.toList(),
        equals(originalListToCreate),
      );

      /// ********************************************
      /// *      CREATE START
      /// ********************************************
      expect(
        originalUpdates.toCreateFromOther.length,
        equals(15),
      );
      expect(
        originalUpdates.toCreateFromOther,
        equals(otherList.getRange(5, 20)),
      );

      /// ********************************************
      /// *      CHECK START
      /// ********************************************
      expect(
        diff.instancesToCheck.length,
        equals(2),
      );
      expect(
        diff.instancesToCheck,
        equals({
          '1': InstanceDiff(
            original: DeletableTestItem(id: '1'),
            other: TestItem('1'),
          ),
          '3': InstanceDiff(
            original: DeletableTestItem(id: '3'),
            other: TestItem('3'),
          ),
        }),
      );
    });
  });
  group('ModelUpdater implementations', () {
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

      // final updated = NoteUpdater.of(
      //   list: existedProjects,
      // ).updateByOther(serverProjects);

      // expect(updated.length, equals(1));
      // expect(updated.first.note, equals(noteModel.note));
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
        projectId: 'p',
      );
      final ideaProjectAnswerModel = IdeaProjectAnswerModel(
        id: id,
        text: 'Because of the world - and future',
        questionId: question.id,
        projectId: 'p',
        createdAt: createdAt,
        updatedAt: updatedAt,
        ownerId: 'user',
      );
      final existedProjects = [ideaProjectAnswer];
      final serverProjects = [ideaProjectAnswerModel];

      // final updated = NoteUpdater.of(
      //   list: existedProjects,
      // ).updateByOther(serverProjects);

      // expect(updated.length, equals(2));
      // expect(updated.first.text, equals(ideaProjectAnswerModel.text));
    });
    test(
      'several idea project answers can be updated by idea answer models',
      () {},
    );
  });
}
