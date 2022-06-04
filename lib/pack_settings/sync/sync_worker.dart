part of pack_settings;

///
/// Offline -> Online strategy
///
/// [] - Get Folders
/// [] - Get Notes
/// [] - Get Idea's questions
/// [] - Get Ideas
/// [] - Get Answers
/// [] - Start subscriptions
///
/// Online -> Offline strategy
///
/// [] - Disable subscriptions
///
class SyncWorker {
  SyncWorker({
    required this.ideaUpdater,
    required this.folderUpdater,
    required this.ideaAnswerUpdater,
    required this.noteUpdater,
    required this.ideaQuestionUpdater,
    required this.context,
  });

  final _subscriptions = [];

  final BuildContext context;

  final FolderUpdater folderUpdater;
  final IdeaAnswerUpdater ideaAnswerUpdater;
  final IdeaQuestionUpdater ideaQuestionUpdater;
  final IdeaUpdater ideaUpdater;
  final NoteUpdater noteUpdater;

  Future<void> onOnline() async {
    await folderUpdater.getAndUpdateByOther();
    await ideaAnswerUpdater.getAndUpdateByOther();
    await ideaQuestionUpdater.getAndUpdateByOther();
    await ideaUpdater.getAndUpdateByOther();
    await noteUpdater.getAndUpdateByOther();
  }

  void onOffline() {}
}
