part of '../widgets.dart';

class SpecialEmojiButton extends HookWidget {
  const SpecialEmojiButton({
    required this.controller,
    required this.focusNode,
    required this.onShowEmojiKeyboard,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onShowEmojiKeyboard;

  @override
  Widget build(final BuildContext context) {
    if (!isNativeDesktop && !kIsWeb) {
      return IconButton(
        onPressed: onShowEmojiKeyboard,
        icon: const Icon(Icons.emoji_flags_rounded),
      );
    }
    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
    );

    return PopupButton(
      icon: Icons.emoji_flags_rounded,
      builder: (final context) => SpecialEmojisGrid(
        onChanged: emojiInserter.insert,
      ),
    );
  }
}
