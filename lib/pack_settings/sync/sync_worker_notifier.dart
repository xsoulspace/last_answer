part of pack_settings;

///
/// Offline -> Online strategy
///
/// [x] - Get Folders
/// [x] - Get Notes
/// [x] - Get Idea's questions
/// [x] - Get Ideas
/// [x] - Get Answers
/// [x] - Start subscriptions
///
/// Online -> Offline strategy
///
/// [x] - Disable subscriptions
///
class SyncWorker extends ChangeNotifier implements Loadable {
  SyncWorker({
    required this.ideaUpdater,
    required this.folderUpdater,
    required this.ideaAnswerUpdater,
    required this.noteUpdater,
    required this.ideaQuestionUpdater,
    required this.connectivityService,
    required this.folderSubscriber,
    required this.ideaAnswerSubscriber,
    required this.ideaQuestionSubscriber,
    required this.ideaSubscriber,
    required this.noteSubscriber,
  });

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    await _onConnectionChange();
    connectivityService.addListener(_onConnectionChange);
  }

  final ConnectivityService connectivityService;

  final FolderUpdater folderUpdater;
  final IdeaAnswerUpdater ideaAnswerUpdater;
  final IdeaQuestionUpdater ideaQuestionUpdater;
  final IdeaUpdater ideaUpdater;
  final NoteUpdater noteUpdater;
  final FolderSubscriber folderSubscriber;
  final IdeaAnswerSubscriber ideaAnswerSubscriber;
  final IdeaQuestionSubscriber ideaQuestionSubscriber;
  final IdeaSubscriber ideaSubscriber;
  final NoteSubscriber noteSubscriber;
  bool inRealTime = false;

  Future<void> goOnline() async {
    if (inRealTime) return;
    await folderUpdater.getAndUpdateByOther();
    await ideaAnswerUpdater.getAndUpdateByOther();
    await ideaQuestionUpdater.getAndUpdateByOther();
    await ideaUpdater.getAndUpdateByOther();
    await noteUpdater.getAndUpdateByOther();
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

  void _subscribe() {
    folderSubscriber.subscribe();
    ideaAnswerSubscriber.subscribe();
    ideaQuestionSubscriber.subscribe();
    ideaSubscriber.subscribe();
    noteSubscriber.subscribe();
    inRealTime = true;
  }

  void _unsubscribe() {
    inRealTime = false;
    folderSubscriber.unsubscribe();
    ideaAnswerSubscriber.unsubscribe();
    ideaQuestionSubscriber.unsubscribe();
    ideaSubscriber.unsubscribe();
    noteSubscriber.unsubscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
