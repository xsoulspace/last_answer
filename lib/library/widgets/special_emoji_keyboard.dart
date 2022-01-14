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

    final emojiKeyboardController = useAnimationController(
      duration: const Duration(milliseconds: 110),
    );
    final emojiKeyboardHeight = useAnimation(
      Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(
          0,
          SpecialEmojisKeyboard.height,
        ),
      ).animate(
        CurvedAnimation(
          parent: emojiKeyboardController,
          curve: Curves.decelerate,
        ),
      ),
    );

    Future<void> _closeEmojiKeyboard({final bool immediately = true}) async {
      if (immediately) {
        emojiKeyboardController.reset();
        isEmojiKeyboardOpen.value = false;
      } else {
        await emojiKeyboardController.reverse();
        isEmojiKeyboardOpen.value = false;
      }
    }

    useEffect(
      () {
        Future.delayed(
          const Duration(milliseconds: 110),
          () {
            final keyboardOpen = window.viewInsets.bottom > 0;
            if (keyboardOpen && isEmojiKeyboardOpen.value) {
              _closeEmojiKeyboard();
            }
          },
        );
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
      onHide: () => _closeEmojiKeyboard(immediately: false),
      onShowKeyboard: () {
        if (focusNode.hasFocus) {
          SoftKeyboard.open();
        } else {
          focusNode.requestFocus();
        }
      },
    );
    void showEmojiKeyboard() {
      emojiKeyboardController.forward();
      SoftKeyboard.close();
      isEmojiKeyboardOpen.value = true;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  child: builder(context, showEmojiKeyboard),
                ),
              ),
              SizedBox(
                height: isEmojiKeyboardOpen.value
                    ? emojiKeyboardHeight.dy
                    : window.viewInsets.bottom / window.devicePixelRatio,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: emojiKeyboardHeight.dy - SpecialEmojisKeyboard.height,
          left: 0,
          right: 0,
          child: Offstage(
            offstage: !isEmojiKeyboardOpen.value,
            child: footer,
          ),
        ),
      ],
    );
  }
}

class SpecialEmojisKeyboard extends HookWidget implements PreferredSizeWidget {
  const SpecialEmojisKeyboard({
    required this.onChanged,
    required this.onShowKeyboard,
    required this.onHide,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  final VoidCallback onShowKeyboard;
  final VoidCallback onHide;
  static const height = 150.0;
  @override
  Size get preferredSize => const Size.fromHeight(height);

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
              Positioned(
                bottom: -5,
                right: 80,
                child: IconButton(
                  iconSize: 45,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  onPressed: onHide,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
