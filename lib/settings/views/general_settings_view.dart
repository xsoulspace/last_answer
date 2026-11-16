import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/widgets/widgets.dart';
import 'package:lastanswer/settings/settings.dart';
import 'package:lastanswer/settings/views/general_settings_bloc.dart';
import 'package:lastanswer/shell/shell_scope.dart';

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

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({this.padding, super.key});
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) => GeneralSettingsProvider(
    builder: (final context) => GeneralSettingsViewBody(padding: padding),
  );
}

class GeneralSettingsViewBody extends StatelessWidget {
  const GeneralSettingsViewBody({this.padding, super.key});
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.watch<ProjectsNotifier>();
    final bloc = context.watch<GeneralSettingsBloc>();
    final userNotifier = context.watch<UserNotifier>();

    return SettingsListContainer(
      padding: padding,
      builder: (final context, final leftColumnWidth) => [
        // Wave N3 — one human actor on this machine: the discoverable
        // entry to their own profile (the actor:<id> surface, avatar
        // and name included).
        SettingsListTile(
          titleText: context.l10n.actorsYourProfile,
          leftColumnWidth: leftColumnWidth,
          child: const _YourProfileButton(),
        ),
        // Glue the SettingsController to the theme selection
        // DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        SettingsListTile(
          titleText: context.l10n.theme,
          leftColumnWidth: leftColumnWidth,
          child: ThemeSwitcherButton(settings: projectsNotifier),
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
        SettingsListTile(
          titleText: context.l10n.storage,
          leftColumnWidth: leftColumnWidth,
          child: const StorageBackendsButton(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: LaHairline(indent: 10, endIndent: 10),
        ),
        SettingsListTile(
          titleText: context.l10n.githubSync,
          leftColumnWidth: leftColumnWidth,
          child: const GithubSyncButton(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: LaHairline(indent: 10, endIndent: 10),
        ),
        SettingsListTile(
          titleText: context.l10n.exportImportData,
          leftColumnWidth: leftColumnWidth,
          child: const ProjectsExportImportButtons(),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: LaHairline(indent: 10, endIndent: 10),
        ),
        Text(context.l10n.note),

        const Gap(24),

        SettingsListTile(
          title: _RestrictionUnblocker(
            child: Text(context.l10n.charactersLimit),
          ),
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
  const _RestrictionUnblocker({required this.child});
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

/// Wave N3 — the human's own profile entry: avatar + name, one tap
/// into their `actor:<id>` surface through the shell's ONE tab router
/// (ViewScope layout showView — the same lane every surface opens by).
class _YourProfileButton extends StatelessWidget {
  const _YourProfileButton();

  @override
  Widget build(final BuildContext context) {
    final service = context.read<RealmChatService?>();
    final human = service?.roster?.all.firstWhereOrNull(
      (final actor) => actor.kind == ActorKind.human,
    );
    return LaButton(
      key: const ValueKey('settings.yourProfile'),
      variant: LaButtonVariant.ghost,
      onPressed: () {
        final scope = ViewScope.of(context);
        if (scope == null || human == null) return;
        scope.onChanged(scope.layout.showView('actor:${human.actorId}'));
      },
      icon: human == null
          ? const Icon(Icons.person_outline, size: 18)
          : ActorAvatar(profile: human, size: 20),
      label: human?.displayName ?? context.l10n.actorsNoneYet,
    );
  }
}
