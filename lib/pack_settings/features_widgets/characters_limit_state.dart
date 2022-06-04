part of pack_settings;

CharactersLimitSettingState useCharactersLimitSettingStateState({
  required final NoteProject? note,
  required final StreamController<NoteProjectUpdate>? updatesStream,
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

class CharactersLimitSettingState extends LifeState {
  CharactersLimitSettingState({
    required this.note,
    required this.updatesStream,
    required this.context,
    required this.controller,
  });

  final BuildContext context;
  final NoteProject? note;
  final StreamController<NoteProjectUpdate>? updatesStream;
  late GeneralSettingsController settings;
  final TextEditingController controller;
  @override
  void initState() {
    settings = context.read<GeneralSettingsController>();
    controller.addListener(onLimitChanged);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(onLimitChanged);
  }

  void onLimitChanged() {
    final limit = int.tryParse(controller.text) ?? 0;
    setLimit(limit);
  }

  static const limitNotifier = NoteProjectUpdate(charactersLimitChanged: true);

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
    setState();
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

  static const int vkLimit = 4096;
  static const String vkLimitStr = '$vkLimit';
  bool get isVkLimit => controller.text == vkLimitStr;
  void onSetVkLimit() {
    final newLimit = isVkLimit ? 0 : vkLimit;
    setLimit(newLimit, updateController: true);
  }

  static const int facebookLimit = 63206;
  static const String facebookLimitStr = '$facebookLimit';
  bool get isFacebookLimit => controller.text == facebookLimitStr;
  void onSetFacebookLimit() {
    final newLimit = isFacebookLimit ? 0 : facebookLimit;
    setLimit(newLimit, updateController: true);
  }

  static const int discordLimit = 2000;
  static const String discordLimitStr = '$discordLimit';
  bool get isDiscordLimit => controller.text == discordLimitStr;
  void onSetDiscordLimit() {
    final newLimit = isDiscordLimit ? 0 : discordLimit;
    setLimit(newLimit, updateController: true);
  }

  bool get noLimitIsSet => controller.text.isEmpty;

  void onClearLimit() {
    setLimit(0, updateController: true);
  }
}
