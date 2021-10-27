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
    final screenLayout = ScreenLayout.of(context);
    if (screenLayout.small && !isDesktop) return const SizedBox();
    return PortalEntry(
      visible: popupVisible.value,
      portalAnchor:
          screenLayout.large ? Alignment.bottomLeft : Alignment.bottomRight,
      childAnchor: screenLayout.large ? Alignment.topRight : Alignment.topLeft,
      portal: EmojiGrid(
        onChanged: (final emoji) {
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
        },
        onClose: () => popupVisible.value = false,
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

class EmojiGrid extends HookConsumerWidget {
  const EmojiGrid({
    required final this.onChanged,
    required final this.onClose,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  final VoidCallback onClose;
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
    Widget emojiButton(final Emoji emoji) => TextButton(
          key: ValueKey(emoji),
          onPressed: () {
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
          },
          child: Center(
            child: Text(emoji.emoji),
          ),
        );
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: defaultBorderRadius,
        side: BorderSide(
          color: borderColor,
        ),
      ),
      child: SizedBox(
        height: 300,
        width: 250,
        child: Stack(
          children: [
            ColoredBox(
              color: theme.canvasColor.withOpacity(0.3),
              child: const SizedBox.expand(),
            ).frosted(
              blur: theme.brightness == Brightness.dark ? 10 : 7,
              frostOpacity: 0.1,
              frostColor: theme.brightness == Brightness.dark
                  ? AppColors.cleanBlack
                  : AppColors.white,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: GridView.count(
                    restorationId: 'emojis-grid',
                    shrinkWrap: true,
                    crossAxisCount: maxItemsInRow,
                    semanticChildCount: emojis.length,
                    padding: const EdgeInsets.only(right: 12),
                    children: emojis.map(emojiButton).toList(),
                  ),
                ),
                Divider(color: borderColor, height: 1),
                Visibility(
                  visible: lastEmojis.value.isNotEmpty,
                  child: Text(
                    S.current.frequentlyUsed,
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.start,
                  ),
                ),
                GridView.count(
                  restorationId: 'last-emojis-grid',
                  shrinkWrap: true,
                  crossAxisCount: maxItemsInRow,
                  semanticChildCount: lastEmojis.value.length,
                  reverse: true,
                  children: lastEmojis.value.map(emojiButton).toList(),
                ),
                Divider(color: borderColor, height: 1),
                Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      IconButton(
                        // constraints: BoxConstraints(maxHeight: 24),
                        icon: const Icon(Icons.close), iconSize: 14,
                        onPressed: onClose,
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: emojiKeywordStream.add,
                          decoration: const InputDecoration()
                              .applyDefaults(theme.inputDecorationTheme)
                              .copyWith(
                                hintText: S.current.search,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
