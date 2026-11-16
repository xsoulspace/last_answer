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
    final laUi = context.laUi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: borderPadding),
        LaRow(
          onTap: onRemove,
          leading: Icon(Icons.delete_outline_rounded, color: laUi.danger),
          titleText: context.l10n.deleteThisNote.sentenceCase,
        ),
        const Gap(borderPadding * 2),
        const SizedBox(height: 4, child: LaHairline()),
        Expanded(
          child: LaPressable.builder(
            showRing: false,
            scaleOnPress: false,
            hoverFill: const Color(0x00000000),
            pressedFill: const Color(0x00000000),
            childBuilder: (final context, final state) => Opacity(
              opacity: state.hovered ? 1.0 : 0.7,
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
                            style: laUi.emphasis,
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
