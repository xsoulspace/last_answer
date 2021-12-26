part of widgets;

class SpecialEmojisKeyboardActions extends HookWidget {
  const SpecialEmojisKeyboardActions({
    required this.builder,
    required final this.controller,
    required this.focusNode,
    final Key? key,
  }) : super(key: key);
  final Widget Function(BuildContext context, VoidCallback onHideEmojiKeyboard)
      builder;
  final FocusNode focusNode;
  final TextEditingController controller;
  @override
  Widget build(final BuildContext context) {
    if (isNativeDesktop || kIsWeb) return builder(context, () {});
    final isEmojiKeyboardOpen = useIsBool();

    useEffect(
      () {
        Future.delayed(const Duration(milliseconds: 110), () {
          final keyboardOpen = window.viewInsets.bottom > 0;
          if (keyboardOpen) {
            isEmojiKeyboardOpen.value = false;
          }
        });
      },
      [window.viewInsets.bottom],
    );

    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
      requestFocusOnInsert: false,
    );
    final footer = SpecialEmojisKeyboard(
      onChanged: emojiInserter.insert,
      onShowKeyboard: () {
        isEmojiKeyboardOpen.value = false;
        if (focusNode.hasFocus) {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        } else {
          focusNode.requestFocus();
        }
      },
    );
    void _hideEmojiKeyboard() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      isEmojiKeyboardOpen.value = true;
    }

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            child: builder(context, _hideEmojiKeyboard),
          ),
        ),
        Offstage(
          offstage: !isEmojiKeyboardOpen.value,
          child: footer,
        ),
      ],
    );
  }
}

class SpecialEmojisKeyboard extends HookWidget implements PreferredSizeWidget {
  const SpecialEmojisKeyboard({
    required this.onChanged,
    required this.onShowKeyboard,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  final VoidCallback onShowKeyboard;
  @override
  Size get preferredSize => const Size.fromHeight(150);

  @override
  Widget build(final BuildContext context) {
    final specialEmojisProvider = context.read<SpecialEmojiProvider>();
    final emojis = specialEmojisProvider.values;
    final theme = Theme.of(context);
    final emojiStyle = theme.textTheme.headline1?.copyWith(fontSize: 26);

    Widget buildEmojiButton(final Emoji emoji) {
      return KeyboardEmojiButton(
        key: ValueKey(emoji),
        emoji: emoji,
        style: emojiStyle,
        onPressed: () => onChanged(emoji),
      );
    }

    return Material(
      child: SizedBox(
        height: preferredSize.height,
        width: preferredSize.width,
        child: Center(
          child: Stack(
            children: [
              GridView.count(
                restorationId: 'special-emojis-grid',
                shrinkWrap: true,
                crossAxisCount: 10,
                semanticChildCount: emojis.length,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                padding: const EdgeInsets.all(12),
                children: emojis.map(buildEmojiButton).toList(),
              ),
              Positioned(
                bottom: -5,
                right: 20,
                child: IconButton(
                  iconSize: 45,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_drop_up_rounded),
                  onPressed: onShowKeyboard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
