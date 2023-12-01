part of '../widgets.dart';

class EmojiPopup extends StatelessWidget {
  const EmojiPopup({
    required this.controller,
    required this.focusNode,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  @override
  Widget build(final BuildContext context) {
    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
    );

    return PopupButton(
      icon: CupertinoIcons.smiley,
      useOnMobile: false,
      onWebClose: () => context.read<EmojiStateNotifier>().filterKeyword = '',
      builder: (final context) => EmojiGrid(
        onChanged: emojiInserter.insert,
      ),
    );
  }
}

class EmojiGrid extends StatelessWidget {
  const EmojiGrid({
    required this.onChanged,
    super.key,
  });
  final ValueChanged<EmojiModel> onChanged;

  @override
  Widget build(final BuildContext context) {
    final emojiNotifier = context.watch<EmojiStateNotifier>();
    final lastEmojisNotifier = context.watch<LastEmojiStateNotifier>();
    final lastEmojis = lastEmojisNotifier.filteredValues;
    final filteredEmoji = emojiNotifier.filteredValues;
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.cleanBlack
        : AppColors.grey4;
    const maxItemsInRow = 9;
    final emojiStyle = PlatformInfo.isNativeDesktop && Platform.isMacOS
        ? null
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'NotoColorEmoji',
            );
    Widget buildEmojiButton(final EmojiModel emoji) => EmojiButton(
          key: ValueKey(emoji),
          style: emojiStyle,
          emoji: emoji,
          onPressed: () {
            onChanged(emoji);
            List<EmojiModel> newLastEmojis = [...lastEmojisNotifier.values];
            final emojiExists = newLastEmojis.contains(emoji);
            if (!emojiExists) {
              newLastEmojis.insert(0, emoji);
            }
            if (newLastEmojis.length > maxItemsInRow && !emojiExists) {
              newLastEmojis = newLastEmojis.sublist(0, maxItemsInRow);
            }
            lastEmojisNotifier.loadIterable(
              values: newLastEmojis,
              toKey: (final c) => c.emoji,
            );
            context.read<LastEmojiStateNotifier>().assignEntries(
                  newLastEmojis.map((final e) => MapEntry(e.emoji, e)),
                );
          },
        );

    return ButtonPopup(
      children: [
        Flexible(
          child: GridView.count(
            restorationId: 'emojis-grid',
            crossAxisCount: maxItemsInRow,
            semanticChildCount: filteredEmoji.length,
            padding: const EdgeInsets.only(right: 12),
            children: filteredEmoji.map(buildEmojiButton).toList(),
          ),
        ),
        Divider(color: borderColor, height: 1),
        Visibility(
          visible: filteredEmoji.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 6,
              bottom: 1,
              left: 9,
            ),
            child: Text(
              context.l10n.frequentlyUsed,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: GridView.count(
            restorationId: 'last-emojis-grid',
            crossAxisCount: maxItemsInRow,
            semanticChildCount: lastEmojis.length,
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            children: lastEmojis.map(buildEmojiButton).toList(),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: UiTextField(
                    onChanged: (final value) {
                      emojiNotifier.filterKeyword = value;
                    },
                    value: emojiNotifier.filterKeyword,
                    decoration: const InputDecoration().copyWith(
                      hintText: context.l10n.search,
                      suffix: IconButton(
                        onPressed: () {
                          emojiNotifier.filterKeyword = '';
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
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
    required this.controller,
    required this.focusNode,
    this.requestFocusOnInsert = true,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool requestFocusOnInsert;

  void insert(final EmojiModel emoji) {
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
      if (focusNode.hasFocus) {
        focusNode.removeListener(addEmoji);
      }
    }

    if (!focusNode.hasFocus && requestFocusOnInsert) {
      if (!focusNode.canRequestFocus) return;
      focusNode
        ..addListener(addEmoji)
        ..requestFocus();
    } else {
      addEmoji();
    }
  }
}
