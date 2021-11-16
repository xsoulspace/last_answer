part of widgets;

class SpecialEmojiButton extends HookWidget {
  const SpecialEmojiButton({
    required final this.controller,
    required final this.focusNode,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;
  @override
  Widget build(final BuildContext context) {
    final popupVisible = useIsBool();
    final screenLayout = ScreenLayout.of(context);
    if (screenLayout.small && !isDesktop) return const SizedBox();
    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
    );
    return PortalEntry(
      visible: popupVisible.value,
      portalAnchor:
          screenLayout.large ? Alignment.bottomLeft : Alignment.bottomRight,
      childAnchor: screenLayout.large ? Alignment.topRight : Alignment.topLeft,
      portal: MouseRegion(
        onExit: (final _) => popupVisible.value = false,
        child: SpecialEmojisGrid(
          onChanged: emojiInserter.inseert,
        ),
      ),
      child: MouseRegion(
        onHover: (final _) => popupVisible.value = true,
        child: IconButton(
          onPressed: () => popupVisible.value = true,
          icon: const Icon(Icons.emoji_emotions),
        ),
      ),
    );
  }
}

class SpecialEmojisGrid extends ConsumerWidget {
  const SpecialEmojisGrid({
    required final this.onChanged,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    Widget buildEmojiButton(final Emoji emoji) {
      return EmojiButton(
        key: ValueKey(emoji),
        emoji: emoji,
        onPressed: () => onChanged(emoji),
      );
    }

    final emojis = ref.watch(specialEmojisProvider).values;
    const maxItemsInRow = 9;

    return ButtonPopup(
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
