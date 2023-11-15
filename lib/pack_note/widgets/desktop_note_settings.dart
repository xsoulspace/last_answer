import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit.dart';
import 'package:lastanswer/pack_settings/features_widgets/characters_limit_state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:recase/recase.dart';

class DesktopNoteSettingsMenu extends HookWidget {
  const DesktopNoteSettingsMenu({
    required this.onRemove,
    required this.characterLimitController,
    super.key,
  });
  static const borderPadding = 8.0;
  final VoidCallback onRemove;
  final CharactersLimitController characterLimitController;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final divider = Divider(
      color: theme.highlightColor,
      height: borderPadding,
      endIndent: borderPadding,
      indent: borderPadding,
    );

    return Column(
      children: [
        const SizedBox(height: borderPadding),
        HovarableListTile(
          onTap: onRemove,
          leadingBuilder: (final context, final hovered) => Icon(
            Icons.delete_outline_rounded,
            color: hovered ? AppColors.accent3 : theme.highlightColor,
          ),
          titleBuilder: (final context, final hovered) => Opacity(
            opacity: hovered ? 1.0 : 0.7,
            child: Text(
              S.current.deleteThisNote.sentenceCase,
            ),
          ),
        ),
        const SizedBox(height: borderPadding * 2),
        divider,
        Expanded(
          child: HoverableArea(
            clickable: false,
            builder: (final context, final hovered) => Opacity(
              opacity: hovered ? 1.0 : 0.7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: borderPadding),
                child: Column(
                  children: [
                    const SizedBox(height: borderPadding * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${S.current.charactersLimit}:',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: CharactersLimitSetting(
                        controller: characterLimitController,
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
