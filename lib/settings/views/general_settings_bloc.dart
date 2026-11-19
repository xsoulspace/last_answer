import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/features.dart';

/// The provider seam the Notes row uses (kept from the retired General
/// view verbatim): one bloc per mount, the limit controller's lifecycle
/// owner.
class GeneralSettingsProvider extends StatelessWidget {
  const GeneralSettingsProvider({required this.builder, super.key});
  final WidgetBuilder builder;
  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
    create: (final context) =>
        GeneralSettingsBloc(dto: GeneralSettingsBlocDto(context: context)),
    builder: (final context, final child) => builder(context),
  );
}

class GeneralSettingsBlocDto {
  GeneralSettingsBlocDto({required this.context})
    : userNotifier = context.read();
  final BuildContext context;
  final UserNotifier userNotifier;
}

class GeneralSettingsBloc with ChangeNotifier {
  GeneralSettingsBloc({required this.dto});
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
