import 'package:lastanswer/common_imports.dart';

class CharactersLimitControllerDto {
  CharactersLimitControllerDto({
    required final BuildContext context,
  }) : globalStateNotifier = context.read<ProjectsNotifier>();
  final ProjectsNotifier globalStateNotifier;
}

class CharactersLimitController extends ValueNotifier<String> {
  CharactersLimitController.fromNote({
    required final ProjectModelNote note,
    required this.dto,
  }) : super(
          _getInitialLimit(
            note: note,
            globalStateNotifier: dto.globalStateNotifier,
          ),
        );
  CharactersLimitController.fromSettings({
    required this.dto,
  }) : super(_getInitialLimit(globalStateNotifier: dto.globalStateNotifier));
  final CharactersLimitControllerDto dto;

  static String _getInitialLimit({
    required final ProjectsNotifier globalStateNotifier,
    final ProjectModelNote? note,
  }) {
    int limit;

    if (note != null && note.id.isEmpty) {
      limit = note.charactersLimit;
    } else {
      limit =
          globalStateNotifier.value.user.settings.charactersLimitForNewNotes;
    }

    return limit == 0 ? '' : '$limit';
  }

  void onLimitChanged(final String? value) {
    final limit = int.tryParse(value ?? '') ?? 0;
    setLimit(limit);
  }

  void setLimit(
    final int newLimit, {
    final bool zeroEqualNull = true,
  }) {
    final str = '$newLimit';
    if (zeroEqualNull && newLimit == 0) {
      setValue('');
    } else {
      setValue(str);
    }
  }

  bool get noLimitIsSet => value.isEmpty;

  void onClearLimit() {
    setLimit(0);
  }

  static const int instagramLimit = 2200;
  static const String instagramLimitStr = '$instagramLimit';
  bool get isInstagramLimit => value == instagramLimitStr;
  void onSetInstagramLimit() {
    final newLimit = isInstagramLimit ? 0 : instagramLimit;
    setLimit(newLimit);
  }

  static const int twitterLimit = 280;
  static const String twitterLimitStr = '$twitterLimit';
  bool get isTwitterLimit => value == twitterLimitStr;
  void onSetTwitterLimit() {
    final newLimit = isTwitterLimit ? 0 : twitterLimit;
    setLimit(newLimit);
  }

  static const int vkLimit = 4096;
  static const String vkLimitStr = '$vkLimit';
  bool get isVkLimit => value == vkLimitStr;
  void onSetVkLimit() {
    final newLimit = isVkLimit ? 0 : vkLimit;
    setLimit(newLimit);
  }

  static const int facebookLimit = 63206;
  static const String facebookLimitStr = '$facebookLimit';
  bool get isFacebookLimit => value == facebookLimitStr;
  void onSetFacebookLimit() {
    final newLimit = isFacebookLimit ? 0 : facebookLimit;
    setLimit(newLimit);
  }

  static const int discordLimit = 2000;
  static const String discordLimitStr = '$discordLimit';
  bool get isDiscordLimit => value == discordLimitStr;
  void onSetDiscordLimit() {
    final newLimit = isDiscordLimit ? 0 : discordLimit;
    setLimit(newLimit);
  }

  static const int telegramLimit = 2200;
  static const String telegramLimitStr = '$telegramLimit';
  bool get isTelegramLimit => value == telegramLimitStr;
  void onSetTelegramLimit() {
    final newLimit = isTelegramLimit ? 0 : telegramLimit;
    setLimit(newLimit);
  }
}
