import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/notifications/notifications_controller.dart';
import 'package:lastanswer/pack_auth/pack_auth.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_purchases/abstract/purchases_abstract.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

/// use for data migrations only
// ignore: unused_element
Future<Box<T>> _openAnyway<T>(final String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    await Hive.deleteBoxFromDisk(boxName);
  }

  return Hive.openBox<T>(boxName);
}

class GlobalStateInitializer implements StateInitializer {
  GlobalStateInitializer({
    required final this.settings,
    required final this.authState,
  });
  final GeneralSettingsController settings;
  final AuthState authState;

  @override
  // ignore: long-method
  Future<void> onLoad({required final BuildContext context}) async {
    /// ********************************************
    /// *      CONTEXT RELATED READINGS START
    /// ********************************************

    final lastEmojiNotifier = context.read<LastEmojiProvider>();
    final specialEmojiNotifier = context.read<SpecialEmojiProvider>();
    final emojiNotifier = context.read<EmojiProvider>();
    final currentFolderNotifier = context.read<CurrentFolderNotifier>();
    final notificationController = context.read<NotificationController>();
    final paymentsController = context.read<PaymentsControllerI>();
    final usersNotifier = context.read<UsersNotifier>();
    final syncWorker = context.read<ServerSyncWorkerNotifier>();
    final connectivity = context.read<ConnectivityNotifier>();

    /// ********************************************
    /// *      CONTEXT RELATED READINGS END
    /// ********************************************

    /// ********************************************
    /// *      CONTENT LOADING START
    /// ********************************************

    /// Loadindependent controllers
    final loadableControllers = <Loadable>[
      settings,
      paymentsController,
      usersNotifier,
    ];
    await Future.forEach<Loadable>(
      loadableControllers,
      (final loadable) => loadable.onLoad(context: context),
    );

    settings.loadingStatus = AppStateLoadingStatuses.emoji;
    // ignore: use_build_context_synchronously
    final emojis = await EmojiUtil.getList(context);

    emojiNotifier.putEntries(emojis.map((final e) => MapEntry(e.emoji, e)));

    // ignore: use_build_context_synchronously
    final specialEmojis = await EmojiUtil.getSpecialList(context);
    specialEmojiNotifier
        .putEntries(specialEmojis.map((final e) => MapEntry(e.emoji, e)));

    final lastUsedEmojis = await EmojiUtil().load();
    lastEmojiNotifier.putAll(lastUsedEmojis);

    settings.loadingStatus = AppStateLoadingStatuses.ideas;

    final answers = await Hive.openBox<IdeaProjectAnswer>(
      HiveBoxesIds.ideaProjectAnswerKey,
    );

    final ideas = await Hive.openBox<IdeaProject>(HiveBoxesIds.ideaProjectKey);

    settings.loadingStatus = AppStateLoadingStatuses.questionsForAnswers;

    final questions = await Hive.openBox<IdeaProjectQuestion>(
      HiveBoxesIds.ideaProjectQuestionKey,
    );

    // TODO(arenukvern): comment if questions changed
    if (questions.isEmpty) {
      await questions.putAll(
        listWithIdToMap(initialQuestions),
      );
    }

    settings.loadingStatus = AppStateLoadingStatuses.answersForIdeas;

    MapState.load<IdeaProjectQuestion, IdeaProjectQuestionsNotifier>(
      context: context,
      box: questions,
    );

    final ideaProjectsState = MapState.load<IdeaProject, IdeaProjectsNotifier>(
      context: context,
      box: ideas,
    );

    final ideaProjectAnswersState =
        MapState.load<IdeaProjectAnswer, IdeaProjectAnswersNotifier>(
      context: context,
      box: answers,
    );

    settings.loadingStatus = AppStateLoadingStatuses.notes;

    final notes = await Hive.openBox<NoteProject>(
      HiveBoxesIds.noteProjectKey,
    );

    final notesProjectsState = MapState.load<NoteProject, NoteProjectsNotifier>(
      context: context,
      box: notes,
    );

    await Hive.openBox<StoryProject>(
      HiveBoxesIds.storyProjectKey,
    );

    final projectsFolders = await Hive.openBox<ProjectFolder>(
      HiveBoxesIds.projectFolderKey,
    );

    final projectsDto = BasicProjectsDto(
      ideas: ideaProjectsState.state,
      notes: notesProjectsState.state,
      // TODO(arenukvern): add stories in future
      stories: const {},
    );

    ProjectFolder currentFolder;

    /// case if project folders is not created
    if (projectsFolders.isEmpty) {
      currentFolder = (await ProjectFolder.create())
        ..addProjects([
          ...ideaProjectsState.state.values,
          ...notesProjectsState.state.values,
        ]);
    } else {
      MapState.load<ProjectFolder, ProjectFoldersNotifier>(
        context: context,
        box: projectsFolders,
      );

      for (final projectsFolder in projectsFolders.values) {
        final projects = ProjectFolder.loadProjectsFromService(
          folder: projectsFolder,
          service: projectsDto,
        );
        projectsFolder.setExistedProjects(projects);
      }

      // TODO(arenukvern): add last used folder
      currentFolder = projectsFolders.values.first;
    }
    currentFolderNotifier.setState(currentFolder);

    /// ********************************************
    /// *      CONTENT LOADING END
    /// ********************************************

    /// ********************************************
    /// *      MIGRATIONS START
    /// ********************************************

    // TODO(arenukvern): keep it in case of future migrations - how to automate it?
    settings.loadingStatus = AppStateLoadingStatuses.migratingOldData;
    if (!settings.migrated) {
      await migrateIdeas_v4(ideas);
      await settings.setMigrated();
    }
    settings.loadingStatus = AppStateLoadingStatuses.settings;

    await notificationController.onLoad(context: context);

    /// ********************************************
    /// *      MIGRATIONS END
    /// ********************************************
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      settings.notify();
    });

    /// ********************************************
    /// *      AUTH START
    /// ********************************************
    await connectivity.onLoad(context: context);
    await authState.recoverSupabaseSession();

    /// ********************************************
    /// *      SYNCHRONIZATION!
    /// ********************************************
    await syncWorker.onLoad(context: context);
  }
}
