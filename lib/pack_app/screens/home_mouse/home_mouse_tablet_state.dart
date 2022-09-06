part of 'home_mouse_tablet_screen.dart';

_ScreenState _useScreenState() => use(
      LifeHook(
        debugLabel: '_ScreenState',
        state: _ScreenState(),
      ),
    );

class _ScreenState extends LifeState {
  _ScreenState();
  void onSwitchLeftPane() {
    leftPaneOpen = !leftPaneOpen;
    setState();
  }

  bool leftPaneOpen = true;
  double leftWidth = 280.0;
}
