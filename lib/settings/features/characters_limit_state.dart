import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/common_imports.dart';

part 'characters_limit_state.freezed.dart';

class CharactersLimitControllerDto {
  CharactersLimitControllerDto({
    required final BuildContext context,
  }) : userNotifier = context.read<UserNotifier>();
  final UserNotifier userNotifier;
}

@freezed
class CharacterLimitState with _$CharacterLimitState {
  const factory CharacterLimitState({
    @Default('') final String value,
    @Default(false) final bool isEditing,
  }) = _CharacterLimitState;
  factory CharacterLimitState.fromDto({
    required final CharactersLimitControllerDto dto,
    final int? noteCharactersLimit,
  }) {
    final initialLimit = _getInitialLimit(
      userNotifier: dto.userNotifier,
      noteCharactersLimit: noteCharactersLimit,
    );
    return CharacterLimitState(
      isEditing: initialLimit.isNotEmpty,
      value: initialLimit,
    );
  }
  static String _getInitialLimit({
    required final UserNotifier userNotifier,
    final int? noteCharactersLimit,
  }) {
    final limit =
        noteCharactersLimit ?? userNotifier.settings.charactersLimitForNewNotes;

    return limit <= 0 ? '' : '$limit';
  }
}

class CharactersLimitController extends ValueNotifier<CharacterLimitState> {
  CharactersLimitController.fromNote({
    required final int noteCharactersLimit,
    required this.dto,
  }) : super(
          CharacterLimitState.fromDto(
            noteCharactersLimit: noteCharactersLimit,
            dto: dto,
          ),
        );
  CharactersLimitController.fromSettings({
    required this.dto,
  }) : super(CharacterLimitState.fromDto(dto: dto));
  final CharactersLimitControllerDto dto;
  final focusNode = FocusNode();
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void onLimitChanged(final String? value) {
    final limit = int.tryParse(value ?? '');
    setLimit(limit);
  }

  // ignore: avoid_positional_boolean_parameters
  void setIsEditing(final bool isEditing) {
    setValue(value.copyWith(isEditing: isEditing));
    if (isEditing) focusNode.requestFocus();
  }

  void setLimit(final int? newLimit, {final bool isEditing = true}) {
    final str = newLimit == null || newLimit <= 0 ? '' : '$newLimit';
    setValue(value.copyWith(value: str, isEditing: isEditing));
  }

  bool get isEditing => value.isEditing;
  String get limit => value.value;

  void onClearLimit() {
    setLimit(null, isEditing: false);
  }

  static const int instagramLimit = 2200;
  static const String instagramLimitStr = '$instagramLimit';
  bool get isInstagramLimit => limit == instagramLimitStr;
  void onSetInstagramLimit() {
    final newLimit = isInstagramLimit ? 0 : instagramLimit;
    setLimit(newLimit);
  }

  static const int twitterLimit = 280;
  static const String twitterLimitStr = '$twitterLimit';
  bool get isXLimit => limit == twitterLimitStr;
  void onSetTwitterLimit() {
    final newLimit = isXLimit ? 0 : twitterLimit;
    setLimit(newLimit);
  }

  static const int vkLimit = 4096;
  static const String vkLimitStr = '$vkLimit';
  bool get isVkLimit => limit == vkLimitStr;
  void onSetVkLimit() {
    final newLimit = isVkLimit ? 0 : vkLimit;
    setLimit(newLimit);
  }

  static const int facebookLimit = 63206;
  static const String facebookLimitStr = '$facebookLimit';
  bool get isFacebookLimit => limit == facebookLimitStr;
  void onSetFacebookLimit() {
    final newLimit = isFacebookLimit ? 0 : facebookLimit;
    setLimit(newLimit);
  }

  static const int discordLimit = 2000;
  static const String discordLimitStr = '$discordLimit';
  bool get isDiscordLimit => limit == discordLimitStr;
  void onSetDiscordLimit() {
    final newLimit = isDiscordLimit ? 0 : discordLimit;
    setLimit(newLimit);
  }

  static const int telegramLimit = 2200;
  static const String telegramLimitStr = '$telegramLimit';
  bool get isTelegramLimit => limit == telegramLimitStr;
  void onSetTelegramLimit() {
    final newLimit = isTelegramLimit ? 0 : telegramLimit;
    setLimit(newLimit);
  }
}
