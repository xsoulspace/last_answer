part of widgets;

class EmojiButton extends StatelessWidget {
  const EmojiButton({
    required final this.onPressed,
    required final this.emoji,
    final Key? key,
  }) : super(key: key);
  final Emoji emoji;
  final VoidCallback onPressed;
  @override
  Widget build(final BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Center(
        child: Text(emoji.emoji),
      ),
    );
  }
}
