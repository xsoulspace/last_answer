part of widgets;

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
    final emojiStyle = Theme.of(context).textTheme.bodyText2;

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
      height: 200,
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
