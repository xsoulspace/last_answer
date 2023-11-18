import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/pack_app/widgets/project_direction_switch.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit.dart';
import 'package:lastanswer/pack_settings/features_widgets/general_settings_bloc.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';

class GeneralSettingsProvider extends StatelessWidget {
  const GeneralSettingsProvider({
    required this.builder,
    super.key,
  });
  final WidgetBuilder builder;
  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final context) => GeneralSettingsBloc(
          dto: GeneralSettingsBlocDto(context: context),
        ),
        builder: (final context, final child) => builder(context),
      );
}

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({
    this.padding,
    super.key,
  });
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) => GeneralSettingsProvider(
        builder: (final context) => GeneralSettingsViewBody(
          padding: padding,
        ),
      );
}

class GeneralSettingsViewBody extends StatelessWidget {
  const GeneralSettingsViewBody({
    this.padding,
    super.key,
  });
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<GlobalStateNotifier>();
    final bloc = context.watch<GeneralSettingsBloc>();

    return SettingsListContainer(
      padding: padding,
      builder: (final context, final leftColumnWidth) => [
        // Glue the SettingsController to the theme selection
        // DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        SettingsListTile(
          title: S.current.theme,
          leftColumnWidth: leftColumnWidth,
          child: ThemeSwitcherButton(
            settings: settings,
          ),
        ),
        SettingsListTile(
          title: S.current.language,
          leftColumnWidth: leftColumnWidth,
          child: LocaleSwitcherButton(
            settings: settings,
          ),
        ),
        SettingsListTile(
          title: S.current.projectsDirection,
          leftColumnWidth: leftColumnWidth,
          child: const ProjectsDirectionSwitch(),
        ),

        Divider(
          color: theme.highlightColor,
          height: 24,
          endIndent: 10,
          indent: 10,
        ),
        Text(S.current.note),

        const SizedBox(height: 24),

        SettingsListTile(
          title: S.current.charactersLimit,
          crossAxisAlignment: CrossAxisAlignment.start,
          leftColumnWidth: leftColumnWidth,
          description: S.current.charactersLimitForNewNotesDesription,
          child: CharactersLimitSetting(
            controller: bloc.characterLimitController,
          ),
        ),

        // ** An Example of how to use link **
        // Link(
        //   uri: Uri.parse('/book/0'),
        //   builder: (context, followLink) => TextButton(
        //     onPressed: followLink,
        //     child: const Text('Go directly to /book/0 (Link)'),
        //   ),
        // ),
      ],
    );
  }
}
