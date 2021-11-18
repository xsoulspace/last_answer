part of widgets;

class EmojiPopup extends HookWidget {
  const EmojiPopup({
    required final this.controller,
    required final this.focusNode,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;
  @override
  Widget build(final BuildContext context) {
    final popupVisible = useIsBool();
    final popupHovered = useIsBool();
    final screenLayout = ScreenLayout.of(context);

    Future<void> onClose() async {
      await Future.delayed(const Duration(milliseconds: 300), () {
        if (popupHovered.value) return;
        popupVisible.value = false;
      });
    }

    if (!isDesktop) return const SizedBox();
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
        onExit: (final _) async {
          popupHovered.value = false;
          await onClose();
        },
        onHover: (final _) => popupHovered.value = true,
        child: EmojiGrid(
          onChanged: emojiInserter.insert,
        ),
      ),
      child: MouseRegion(
        onHover: (final _) => popupVisible.value = true,
        onExit: (final _) async => onClose(),
        child: IconButton(
          onPressed: () => popupVisible.value = true,
          icon: const Icon(Icons.emoji_emotions),
        ),
      ),
    );
  }
}

class EmojiGrid extends HookConsumerWidget {
  const EmojiGrid({
    required final this.onChanged,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final emojis = ref.watch(filteredEmojisProvider);
    final lastEmojisState = ref.watch(lastUsedEmojisProvider);
    // ignore: close_sinks
    final emojiKeywordStream = useStreamController<String>();
    emojiKeywordStream.stream
        .throttleTime(
      const Duration(milliseconds: 700),
      leading: true,
      trailing: true,
    )
        .forEach((final keyword) async {
      ref.read(emojiFilterProvider).state = keyword;
    });
    final lastEmojis = useState(lastEmojisState.values.toSet());
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.cleanBlack
        : AppColors.grey4;
    const maxItemsInRow = 9;

    Widget buildEmojiButton(final Emoji emoji) {
      void onPressed() {
        onChanged(emoji);
        List<Emoji> newLastEmojis = [...lastEmojis.value];
        final emojiExists = newLastEmojis.contains(emoji);
        if (!emojiExists) {
          newLastEmojis.insert(0, emoji);
        }
        if (newLastEmojis.length > maxItemsInRow && !emojiExists) {
          newLastEmojis = newLastEmojis.sublist(0, maxItemsInRow);
        }
        lastEmojis.value = newLastEmojis.toSet();

        ref.read(lastUsedEmojisProvider.notifier).assignEntries(
              newLastEmojis.map((final e) => MapEntry(e.emoji, e)),
            );
      }

      return EmojiButton(
        key: ValueKey(emoji),
        emoji: emoji,
        onPressed: onPressed,
      );
    }

    return ButtonPopup(
      children: [
        Expanded(
          child: GridView.count(
            restorationId: 'emojis-grid',
            shrinkWrap: true,
            crossAxisCount: maxItemsInRow,
            semanticChildCount: emojis.length,
            padding: const EdgeInsets.only(right: 12),
            children: emojis.map(buildEmojiButton).toList(),
          ),
        ),
        Divider(color: borderColor, height: 1),
        Visibility(
          visible: lastEmojis.value.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 6,
              bottom: 1,
              left: 9,
            ),
            child: Text(
              S.current.frequentlyUsed,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        GridView.count(
          restorationId: 'last-emojis-grid',
          shrinkWrap: true,
          crossAxisCount: maxItemsInRow,
          semanticChildCount: lastEmojis.value.length,
          reverse: true,
          children: lastEmojis.value.map(buildEmojiButton).toList(),
        ),
        Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: emojiKeywordStream.add,
                    decoration: const InputDecoration()
                        .applyDefaults(theme.inputDecorationTheme)
                        .copyWith(hintText: S.current.search),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EmojiInserter {
  EmojiInserter.use({
    required final this.controller,
    required final this.focusNode,
  });
  final TextEditingController controller;
  final FocusNode focusNode;

  void insert(final Emoji emoji) {
    void addEmoji() {
      final emojiChar = emoji.emoji;
      // Get cursor current position
      final cursorPos = controller.selection.base.offset;

      // Right text of cursor position
      final suffixText = controller.text.substring(cursorPos);

      // Add new text on cursor position
      final length = emojiChar.length;

      // Get the left text of cursor
      final prefixText = controller.text.substring(0, cursorPos);
      controller
        ..text = prefixText + emojiChar + suffixText

        // Cursor move to end of added text
        ..selection = TextSelection(
          baseOffset: cursorPos + length,
          extentOffset: cursorPos + length,
        );
      focusNode.removeListener(addEmoji);
    }

    if (!focusNode.hasFocus) {
      if (!focusNode.canRequestFocus) return;
      focusNode
        ..addListener(addEmoji)
        ..requestFocus();
    } else {
      addEmoji();
    }
  }
}
