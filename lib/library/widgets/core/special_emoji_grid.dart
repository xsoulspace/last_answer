part of widgets;

class SpecialEmojiPopup extends HookWidget {
  const SpecialEmojiPopup({
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
          hideBorder: true,
        );
      },
    );
  }
}

class SpecialEmojisGrid extends StatelessWidget {
  const SpecialEmojisGrid({
    required final this.onChanged,
    final this.hideBorder = false,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  final bool hideBorder;
  @override
  Widget build(final BuildContext context) {
    final emojiStyle = isNativeDesktop && Platform.isMacOS
        ? null
        : Theme.of(context).textTheme.bodyText2?.copyWith(
              fontFamily: 'NotoColorEmoji',
            );
    Widget buildEmojiButton(final Emoji emoji) {
      return EmojiButton(
        key: ValueKey(emoji),
        emoji: emoji,
        style: emojiStyle,
        onPressed: () => onChanged(emoji),
      );
    }

    final specialEmojisProvider = context.read<SpecialEmojiProvider>();
    final emojis = specialEmojisProvider.values;
    const maxItemsInRow = 9;

    return ButtonPopup(
      height: 80,
      hideBorder: hideBorder,
      children: [
        Expanded(
          child: GridView.count(
            restorationId: 'special-emojis-grid',
            shrinkWrap: true,
            crossAxisCount: maxItemsInRow,
            semanticChildCount: emojis.length,
            padding: const EdgeInsets.only(right: 12),
            children: emojis.map(buildEmojiButton).toList(),
          ),
        ),
      ],
    );
  }
}
