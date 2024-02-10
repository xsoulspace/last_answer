part of 'state.dart';

class LocalUserInitializer {
  LocalUserInitializer(final BuildContext context)
      : dto = GlobalStatesInitializerDto(context: context);
  final GlobalStatesInitializerDto dto;
  Future<void> onUserLoad() async {
    await runMutations(dto);

    /// not wait for this since every data has its own loader
    unawaited(_onLoadData());
  }

  Future<void> _onLoadData() async {
    dto.projectsNotifier.onReset();

    /// refreshing data, just to make sure all is loaded correctly
    await Future.delayed(const Duration(seconds: 1));
    await dto.projectsNotifier.onLocalUserLoad();
    await dto.purchasesNotifier.onLocalUserLoad();
  }

  void onUserReset() {
    dto.projectsNotifier.onReset();
  }
}
