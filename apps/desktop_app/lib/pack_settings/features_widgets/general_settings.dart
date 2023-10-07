import 'package:flutter/material.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_settings/abstract/general_settings_controller.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit.dart';
import 'package:lastanswer/pack_settings/features_widgets/locale_switcher_button.dart';
import 'package:lastanswer/pack_settings/features_widgets/theme_switcher_button.dart';
import 'package:lastanswer/pack_settings/widgets/settings_list_container.dart';
import 'package:lastanswer/pack_settings/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({
    this.padding,
    final Key? key,
  }) : super(key: key);
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<GeneralSettingsController>();

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
          child: ProjectsDirectionSwitch(
            settings: settings,
          ),
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
          child: const CharactersLimitSetting(),
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
