part of pack_settings;

SmallSettingsScreenState useSmallSettingsScreenStateState() => use(
      LifeHook(
        debugLabel: 'SmallSettingsScreenState',
        state: SmallSettingsScreenState(),
      ),
    );

class SmallSettingsScreenState implements LifeState {
  SmallSettingsScreenState();

  @override
  ValueChanged<VoidCallback>? setState;

  @override
  void initState() {
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
