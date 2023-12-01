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
