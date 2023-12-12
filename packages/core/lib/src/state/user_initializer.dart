part of 'state.dart';

class UserInitializer {
  UserInitializer({required this.dto});
  final GlobalStatesInitializerDto dto;
  Future<void> onUserLoad() async {
    final isAnyMigrationsExecuted = await runMutations(dto);
    if (isAnyMigrationsExecuted) {
      /// not wait for this since it has its own loader
      unawaited(_onDelayedLoad());
    } else {
      unawaited(dto.projectsNotifier.onLoad());
    }
  }

  Future<void> _onDelayedLoad() async {
    /// refreshing data, just to make sure all is loaded
    await Future.delayed(const Duration(seconds: 1));
    dto.projectsNotifier.onReset();
    await dto.projectsNotifier.onLoad();
  }

  void onUserReset() {
    dto.projectsNotifier.onReset();
  }
}

class RemoteUserInitializer {
  RemoteUserInitializer({required this.dto}) {
    _sessionManager.addListener(_onSessionChanged);
  }
  final GlobalStatesInitializerDto dto;
  SessionManager get _sessionManager =>
      (dto.remoteClient as RemoteClientServerpodImpl).sessionManager;
  Future<void> onUserLoad() async {
    /// add any methods to load remote data
  }

  void _onSessionChanged() {
    if (_sessionManager.isSignedIn) {
      unawaited(dto.userNotifier.loadRemoteUser());
    } else {
      dto.userNotifier.resetRemoteUser();
    }
  }

  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
  }
}
