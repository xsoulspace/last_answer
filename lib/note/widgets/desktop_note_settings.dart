import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/settings.dart';

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              context.l10n.deleteThisNote.sentenceCase,
            ),
          ),
        ),
        const Gap(borderPadding * 2),
        const Divider(height: 4, thickness: 4),
        Expanded(
          child: HoverableArea(
            clickable: false,
            builder: (final context, final hovered) => Opacity(
              opacity: hovered ? 1.0 : 0.7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: borderPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: borderPadding * 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${context.l10n.charactersLimit}:',
                            textAlign: TextAlign.left,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const Gap(2),
                    Expanded(
                      child: CharactersLimitSetting(
                        controller: characterLimitController,
                      ),
                    ),
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
