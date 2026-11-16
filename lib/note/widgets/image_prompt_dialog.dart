import 'package:lastanswer/common_imports.dart';

/// The one generate-prompt dialog both image flows share (attach-sheet
/// T2I and the edit sheet's I2I variation): a title, a prompt field,
/// cancel/generate. Answers the trimmed-empty-checked raw text; null
/// means the human dismissed.
Future<String?> askImagePrompt(final BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (final dialogContext) => AlertDialog(
      title: Text(dialogContext.l10n.generateImage),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: dialogContext.l10n.imageGenerationPrompt,
        ),
        onSubmitted: (final value) => Navigator.of(dialogContext).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(dialogContext.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: Text(dialogContext.l10n.generateImage),
        ),
      ],
    ),
  );
}
