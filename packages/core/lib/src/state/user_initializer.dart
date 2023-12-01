part of 'state.dart';

class UserInitializer {
  UserInitializer({required this.dto});
  final GlobalStatesInitializerDto dto;
  Future<void> onUserLoad() async {
    await runMutations(dto);

    /// not wait for this since it has its own loader
    unawaited(_onDelayedLoad());
  }

  Future<void> _onDelayedLoad() async {
    await Future.delayed(const Duration(seconds: 1));
    await dto.projectsNotifier.onLoad();
  }

  void onUserReset() {
    dto.projectsNotifier.onReset();
  }
}
