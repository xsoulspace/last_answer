part of 'home_mouse_tablet_screen.dart';

class _DiDto {
  _DiDto.use(final Locator read) : appRouterController = read();
  final AppRouterController appRouterController;
}

_ScreenState _useScreenState({
  required final Locator read,
}) =>
    use(
      LifeHook(
        debugLabel: '_ScreenState',
        state: _ScreenState(
          diDto: _DiDto.use(read),
        ),
      ),
    );

class _ScreenState extends LifeState {
  _ScreenState({
    required this.diDto,
  });
  final _DiDto diDto;
  void onShowInfo() {
    diDto.appRouterController.toAppInfo();
  }

  void onShowSettings() {
    diDto.appRouterController.toSettings();
  }

  void onSwitchLeftPane() {
    leftPaneOpen = !leftPaneOpen;
    setState();
  }

  bool leftPaneOpen = true;
  double leftWidth = 280;
}
