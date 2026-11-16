import 'package:lastanswer/common_imports.dart';

/// The one generate-prompt dialog both image flows share (attach-sheet
/// T2I and the edit sheet's I2I variation): a title, a prompt field,
/// cancel/generate. Answers the trimmed-empty-checked raw text; null
/// means the human dismissed.
Future<String?> askImagePrompt(final BuildContext context) {
  final controller = TextEditingController();
  return showLaDialog<String>(
    context: context,
    builder: (final dialogContext) => LaDialog(
      titleText: dialogContext.l10n.generateImage,
      content: LaField(
        controller: controller,
        autofocus: true,
        placeholder: dialogContext.l10n.imageGenerationPrompt,
        onSubmitted: (final value) => Navigator.of(dialogContext).pop(value),
      ),
      actions: [
        LaButton(
          label: dialogContext.l10n.cancel,
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        LaButton(
          label: dialogContext.l10n.generateImage,
          variant: LaButtonVariant.primary,
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
        ),
      ],
    ),
  );
}
