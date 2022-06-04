part of pack_settings;

///
/// Offline -> Online strategy
///
/// [x] - Get Folders
/// [x] - Get Notes
/// [x] - Get Idea's questions
/// [x] - Get Ideas
/// [x] - Get Answers
/// [] - Start subscriptions
///
/// Online -> Offline strategy
///
/// [] - Disable subscriptions
///
class SyncWorker extends ChangeNotifier implements Loadable {
  SyncWorker({
    required this.ideaUpdater,
    required this.folderUpdater,
    required this.ideaAnswerUpdater,
    required this.noteUpdater,
    required this.ideaQuestionUpdater,
    required this.context,
  });

  @override
  Future<void> onLoad({required final BuildContext context}) {
    // TODO: implement onLoad
    throw UnimplementedError();
  }

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
    _subscribe();
  }

  void onOffline() {
    _unsubscribe();
  }

  void _subscribe() {}
  void _unsubscribe() {}
}
