import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/widgets/widgets.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:lastanswer/settings/views/general_settings_bloc.dart';

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
    final projectsNotifier = context.watch<ProjectsNotifier>();
    final bloc = context.watch<GeneralSettingsBloc>();
    final userNotifier = context.watch<UserNotifier>();

    return SettingsListContainer(
      padding: padding,
      builder: (final context, final leftColumnWidth) => [
        // Glue the SettingsController to the theme selection
        // DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        SettingsListTile(
          titleText: context.l10n.theme,
          leftColumnWidth: leftColumnWidth,
          child: ThemeSwitcherButton(
            settings: projectsNotifier,
          ),
        ),
        SettingsListTile(
          titleText: context.l10n.language,
          leftColumnWidth: leftColumnWidth,
          child: const LocaleSwitcherButton(),
        ),
        SettingsListTile(
          titleText: context.l10n.projectsDirection,
          leftColumnWidth: leftColumnWidth,
          child: const ProjectsDirectionSwitch(),
        ),
        Divider(
          color: theme.highlightColor,
          height: 24,
          endIndent: 10,
          indent: 10,
        ),
        SettingsListTile(
          titleText: context.l10n.exportImportData,
          leftColumnWidth: leftColumnWidth,
          child: const ProjectsExportImportButtons(),
        ),

        Divider(
          color: theme.highlightColor,
          height: 24,
          endIndent: 10,
          indent: 10,
        ),
        Text(context.l10n.note),

        const Gap(24),

        SettingsListTile(
          title:
              _RestrictionUnblocker(child: Text(context.l10n.charactersLimit)),
          crossAxisAlignment: CrossAxisAlignment.start,
          leftColumnWidth: leftColumnWidth,
          description: context.l10n.charactersLimitForNewNotesDesription,
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

class _RestrictionUnblocker extends HookWidget {
  const _RestrictionUnblocker({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final counter = useState(0);
    final userNotifier = context.read<UserNotifier>();
    return GestureDetector(
      onTap: () {
        counter.value++;
        if (counter.value > 10) userNotifier.disableRestrictions();
      },
      child: child,
    );
  }
}
