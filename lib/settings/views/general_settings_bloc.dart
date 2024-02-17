import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/features.dart';

class GeneralSettingsBlocDto {
  GeneralSettingsBlocDto({
    required this.context,
  }) : userNotifier = context.read();
  final BuildContext context;
  final UserNotifier userNotifier;
}

class GeneralSettingsBloc with ChangeNotifier {
  GeneralSettingsBloc({
    required this.dto,
  });
  late final CharactersLimitController characterLimitController =
      CharactersLimitController.fromSettings(
    dto: CharactersLimitControllerDto(context: dto.context),
  )..addListener(_onChanged);
  final GeneralSettingsBlocDto dto;

  void _onChanged() {
    dto.userNotifier.updateCharactersLimitForNewNotes(
      int.tryParse(characterLimitController.limit) ?? 0,
    );
  }

  @override
  void dispose() {
    characterLimitController
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }
}
