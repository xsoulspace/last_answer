import 'package:flutter/material.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit_state.dart';

class GeneralSettingsBlocDto {
  GeneralSettingsBlocDto({
    required this.context,
  });
  final BuildContext context;
}

class GeneralSettingsBloc with ChangeNotifier {
  GeneralSettingsBloc({
    required this.dto,
  }) : characterLimitController = CharactersLimitController.fromSettings(
          dto: CharactersLimitControllerDto(context: dto.context),
        );
  final CharactersLimitController characterLimitController;
  final GeneralSettingsBlocDto dto;
}
