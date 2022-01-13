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
  ValueChanged<VoidCallback>? setState;

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

  void setLimit(
    final int newLimit, {
    final bool updateController = false,
    final bool zeroEqualNull = true,
  }) {
    if (note == null) {
      settings.charactersLimitForNewNotes = newLimit;
    } else {
      note?.charactersLimit = newLimit;
      updatesStream?.add(limitNotifier);
    }
    if (updateController) {
      String effectiveLimit = '$newLimit';
      if (zeroEqualNull && newLimit == 0) {
        effectiveLimit = '';
      }
      controller.text = effectiveLimit;
    }
    setState?.call(() {});
  }

  static const int instagramLimit = 2200;
  static const String instagramLimitStr = '$instagramLimit';
  bool get isInstagramLimit => controller.text == instagramLimitStr;
  void onSetInstagramLimit() {
    final newLimit = isInstagramLimit ? 0 : instagramLimit;
    setLimit(newLimit, updateController: true);
  }

  static const int twitterLimit = 280;
  static const String twitterLimitStr = '$twitterLimit';
  bool get isTwitterLimit => controller.text == twitterLimitStr;
  void onSetTwitterLimit() {
    final newLimit = isTwitterLimit ? 0 : twitterLimit;
    setLimit(newLimit, updateController: true);
  }

  bool get noLimitIsSet => controller.text.isEmpty;

  void onClearLimit() {
    setLimit(0, updateController: true);
  }
}
