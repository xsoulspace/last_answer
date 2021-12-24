part of pack_settings;

CharactersLimitSettingState useCharactersLimitSettingStateState({
  required final NoteProject? note,
  required final StreamController<NoteProjectNotifier>? updatesStream,
  required final BuildContext context,
  required final TextEditingController controller,
}) =>
    use(
      LifeHook(
        debugLabel: 'useCharactersLimitSettingStateState',
        state: CharactersLimitSettingState(
          note: note,
          updatesStream: updatesStream,
          context: context,
          controller: controller,
        ),
      ),
    );

class CharactersLimitSettingState implements LifeState {
  CharactersLimitSettingState({
    required this.note,
    required this.updatesStream,
    required this.context,
    required this.controller,
  });

  @override
  late ValueChanged<VoidCallback> setState;
  final BuildContext context;
  final NoteProject? note;
  final StreamController<NoteProjectNotifier>? updatesStream;
  late SettingsController settings;
  final TextEditingController controller;
  @override
  void initState() {
    settings = context.read<SettingsController>();
    controller.addListener(onLimitChanged);
  }

  @override
  void dispose() {
    controller.removeListener(onLimitChanged);
  }

  void onLimitChanged() {
    final limit = int.tryParse(controller.text) ?? 0;
    setLimit(limit);
  }

  static const limitNotifier =
      NoteProjectNotifier(charactersLimitChanged: true);

  void setLimit(final int newLimit, {final bool updateController = false}) {
    if (note == null) {
      settings.charactersLimitForNewNotes = newLimit;
    } else {
      note?.charactersLimit = newLimit;
      updatesStream?.add(limitNotifier);
    }
    if (updateController) {
      controller.text = newLimit == 0 ? '' : '$newLimit';
    }
    setState(() {});
  }

  void onSetInstagramLimit() {
    setLimit(2200, updateController: true);
  }

  void onClearLimit() {
    setLimit(0, updateController: true);
  }
}
