part of widgets;

class SpecialEmojiButton extends HookWidget {
  const SpecialEmojiButton({
    required final this.controller,
    required final this.focusNode,
    required final this.onShowEmojiKeyboard,
    final Key? key,
  }) : super(key: key);
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
      builder: (final context) {
        return SpecialEmojisGrid(
          onChanged: emojiInserter.insert,
        );
      },
    );
  }
}