part of widgets;

class SpecialEmojisKeyboardActions extends StatelessWidget {
  const SpecialEmojisKeyboardActions({
    required this.child,
    required final this.controller,
    required this.focusNode,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  final FocusNode focusNode;
  final TextEditingController controller;
  @override
  Widget build(final BuildContext context) {
    if (isNativeDesktop) return child;

    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
    );

    return KeyboardActions(
      autoScroll: false,
      config: KeyboardActionsConfig(
        actions: [
          KeyboardActionsItem(
            focusNode: focusNode,
            displayActionBar: false,
            footerBuilder: (final _) => SpecialEmojiListActions(
              onChanged: emojiInserter.insert,
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SpecialEmojiListActions extends HookWidget
    implements PreferredSizeWidget {
  const SpecialEmojiListActions({
    required this.onChanged,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(final BuildContext context) {
    final emojisEnabled = useIsBool();
    final specialEmojisProvider = context.read<SpecialEmojiProvider>();
    final emojis = specialEmojisProvider.values;
    final theme = Theme.of(context);
    final emojiStyle = theme.textTheme.headline1?.copyWith(fontSize: 26);

    Widget buildEmojiButton(final BuildContext context, final int index) {
      final emoji = emojis[index];

      return KeyboardEmojiButton(
        key: ValueKey(emoji),
        emoji: emoji,
        style: emojiStyle,
        onPressed: () => onChanged(emoji),
      );
    }

    return Material(
      elevation: 4,
      // color: theme.canvasColor,
      child: SizedBox(
        height: preferredSize.height,
        width: preferredSize.width,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: emojisEnabled.value
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: buildEmojiButton,
                          itemCount: emojis.length,
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(8.0).copyWith(right: 0),
                        onPressed: () {
                          emojisEnabled.value = false;
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    ],
                  ),
                )
              : Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.emoji_flags_rounded),
                    onPressed: () {
                      emojisEnabled.value = true;
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
