part of widgets;

class EmojiButton extends StatelessWidget {
  const EmojiButton({
    required final this.onPressed,
    required final this.emoji,
    required final this.style,
    final Key? key,
  }) : super(key: key);
  final Emoji emoji;
  final VoidCallback onPressed;
  final TextStyle? style;
  @override
  Widget build(final BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Center(
        child: Text(
          emoji.emoji,
          style: style,
        ),
      ),
    );
  }
}

class KeyboardEmojiButton extends StatelessWidget {
  const KeyboardEmojiButton({
    required final this.onPressed,
    required final this.emoji,
    this.style,
    final Key? key,
  }) : super(key: key);
  final Emoji emoji;
  final VoidCallback onPressed;
  final TextStyle? style;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: CupertinoButton(
        minSize: 0,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: Container(
          width: 30,
          height: 40,
          decoration: BoxDecoration(
            color: theme.highlightColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(5),
          child: FittedBox(
            child: Text(
              emoji.emoji,
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}
