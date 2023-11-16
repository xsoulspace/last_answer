part of '../widgets.dart';

class EmojiButton extends StatelessWidget {
  const EmojiButton({
    required this.onPressed,
    required this.emoji,
    required this.style,
    super.key,
  });
  final EmojiModel emoji;
  final VoidCallback onPressed;
  final TextStyle? style;
  @override
  Widget build(final BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CupertinoButton(
          minSize: 0,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Center(
            child: Text(
              emoji.emoji,
              style: style,
            ),
          ),
        ),
      );
}

class KeyboardEmojiButton extends StatelessWidget {
  const KeyboardEmojiButton({
    required this.onPressed,
    required this.emoji,
    this.style,
    super.key,
  });
  final EmojiModel emoji;
  final VoidCallback onPressed;
  final TextStyle? style;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoButton(
      minSize: 0,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Container(
        width: 35,
        height: 40,
        decoration: BoxDecoration(
          color: theme.highlightColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.all(7),
        child: FittedBox(
          child: Text(
            emoji.emoji,
            style: style,
          ),
        ),
      ),
    );
  }
}
