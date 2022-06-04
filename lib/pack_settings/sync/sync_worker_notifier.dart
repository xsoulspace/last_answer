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
    required this.connectivityService,
  });

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    await _onConnectionChange();
  }

  final ConnectivityService connectivityService;

  final FolderUpdater folderUpdater;
  final IdeaAnswerUpdater ideaAnswerUpdater;
  final IdeaQuestionUpdater ideaQuestionUpdater;
  final IdeaUpdater ideaUpdater;
  final NoteUpdater noteUpdater;

  Future<void> goOnline() async {
    await folderUpdater.getAndUpdateByOther();
    await ideaAnswerUpdater.getAndUpdateByOther();
    await ideaQuestionUpdater.getAndUpdateByOther();
    await ideaUpdater.getAndUpdateByOther();
    await noteUpdater.getAndUpdateByOther();
    connectivityService.addListener(_onConnectionChange);
    _subscribe();
  }

  Future<void> _onConnectionChange() async {
    final isConnected = connectivityService.isConnected;
    if (isConnected) {
      await goOnline();
    } else {
      goOffline();
    }
  }

  void goOffline() {
    _unsubscribe();
  }

  void _subscribe() {}
  void _unsubscribe() {}

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
