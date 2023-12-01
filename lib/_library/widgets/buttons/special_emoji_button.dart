import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class SpecialEmojiButton extends StatelessWidget {
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
