import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/buttons/popup_button.dart';
import 'package:lastanswer/library/widgets/widgets.dart';

class SpecialEmojiButton extends HookWidget {
  const SpecialEmojiButton({
    required this.controller,
    super.key,
  });
  final SpecialEmojiController controller;

  @override
  Widget build(final BuildContext context) {
    if (!PlatformInfo.isNativeDesktop && !PlatformInfo.isWeb) {
      return IconButton(
        onPressed: controller.switchEmojiKeyboard,
        icon: const Icon(Icons.emoji_flags_rounded),
      );
    }

    return PopupButton(
      icon: Icons.emoji_flags_rounded,
      builder: (final context) => SpecialEmojisGrid(
        onChanged: controller.emojiInserter.insert,
      ),
    );
  }
}
