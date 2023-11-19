part of 'state.dart';

class UserInitializer {
  UserInitializer({required this.dto});
  final GlobalStatesInitializerDto dto;
  Future<void> onUserLoad() async {
    await runMutations(dto);

    /// not wait projects since it has its own loader
    unawaited(dto.projectsNotifier.onLoad());
  }

  void onUserReset() {
    dto.projectsNotifier.onReset();
  }
}
