part of pack_settings;

ServerSyncWorkerNotifier createServerSyncWorkerNotifier(
  final BuildContext context,
) =>
    ServerSyncWorkerNotifier(
      ideaUpdater: context.read(),
      folderUpdater: context.read(),
      ideaAnswerUpdater: context.read(),
      noteUpdater: context.read(),
      ideaQuestionUpdater: context.read(),
      connectivityService: context.read(),
      folderSubscriber: context.read(),
      projectsSubscriber: context.read(),
      ideaQuestionSubscriber: context.read(),
      ideaAnswerSubscriber: context.read(),
      serverProjectsSyncService: context.read(),
      usersNotifier: context.read(),
    );

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
class ServerSyncWorkerNotifier extends ChangeNotifier implements Loadable {
  ServerSyncWorkerNotifier({
    required this.ideaUpdater,
    required this.folderUpdater,
    required this.ideaAnswerUpdater,
    required this.noteUpdater,
    required this.ideaQuestionUpdater,
    required this.connectivityService,
    required this.folderSubscriber,
    required this.projectsSubscriber,
    required this.ideaQuestionSubscriber,
    required this.ideaAnswerSubscriber,
    required this.serverProjectsSyncService,
    required this.usersNotifier,
  });

  @override
  Future<void> onLoad({required final BuildContext context}) async {
    await _onConnectionChange();
    connectivityService.addListener(_onConnectionChange);
    usersNotifier.authenticated.addListener(_onAuthChange);
  }

  final ConnectivityNotifier connectivityService;

  final ServerProjectsSyncService serverProjectsSyncService;

  final FolderUpdater folderUpdater;
  final IdeaAnswerUpdater ideaAnswerUpdater;
  final IdeaQuestionUpdater ideaQuestionUpdater;
  final IdeaUpdater ideaUpdater;
  final NoteUpdater noteUpdater;
  final ServerFolderSubscriber folderSubscriber;
  final ServerIdeaAnswerSubscriber ideaAnswerSubscriber;
  final ServerIdeaQuestionSubscriber ideaQuestionSubscriber;
  final ServerProjectsSubscriber projectsSubscriber;
  final UsersNotifier usersNotifier;

  bool inRealTime = false;

  Future<void> goOnline() async {
    if (inRealTime) return;
    await folderUpdater.getAndUpdateByOther();
    final projects = await serverProjectsSyncService.getAll();
    await ideaUpdater.updateByUnion(projects);
    await ideaQuestionUpdater.getAndUpdateByOther();
    await ideaAnswerUpdater.getAndUpdateByOther();
    await noteUpdater.updateByUnion(projects);
    _subscribe();
  }

  Future<void> _onConnectionChange() async {
    final isConnected = connectivityService.isConnected;
    if (isConnected) {
      if (!usersNotifier.authenticated.value) return;

      await goOnline();
    } else {
      goOffline();
    }
  }

  Future<void> _onAuthChange() async {
    if (usersNotifier.authenticated.value) {
      await _onConnectionChange();
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
    projectsSubscriber.subscribe();
    inRealTime = true;
  }

  void _unsubscribe() {
    inRealTime = false;
    folderSubscriber.unsubscribe();
    ideaAnswerSubscriber.unsubscribe();
    ideaQuestionSubscriber.unsubscribe();
    projectsSubscriber.unsubscribe();
  }

  @override
  void dispose() {
    usersNotifier.authenticated.removeListener(_onAuthChange);
    connectivityService.removeListener(_onConnectionChange);
    _unsubscribe();
    super.dispose();
  }
}
