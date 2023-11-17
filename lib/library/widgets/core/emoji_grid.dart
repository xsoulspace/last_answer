part of '../widgets.dart';

class EmojiPopup extends HookWidget {
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
      builder: (final context) => EmojiGrid(
        onChanged: emojiInserter.insert,
      ),
    );
  }
}

class EmojiGrid extends HookWidget {
  const EmojiGrid({
    required this.onChanged,
    super.key,
  });
  final ValueChanged<EmojiModel> onChanged;

  // Widget buildConsumer({
  //   required final BuildContext context,
  //   required final StreamController<String> emojiKeywordStream,
  // }){

  // }

  @override
  Widget build(final BuildContext context) {
    final silentEmojiProider = context.read<EmojiStateNotifier>();
    final lastEmojisState = context.read<LastEmojiStateNotifier>().values;
    // ignore: close_sinks
    final emojiKeywordStream = useStreamController<String>(
      onCancel: () {
        silentEmojiProider.filterKeyword = '';
      },
    );

    unawaited(
      emojiKeywordStream.stream
          .sampleTime(
        const Duration(milliseconds: 700),
      )
          .forEach(
        (final keyword) {
          silentEmojiProider.filterKeyword = keyword;
        },
      ),
    );
    final lastEmojis = useState(lastEmojisState.toSet());
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.cleanBlack
        : AppColors.grey4;
    const maxItemsInRow = 9;
    final emojiStyle = isNativeDesktop && Platform.isMacOS
        ? null
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'NotoColorEmoji',
            );
    Widget buildEmojiButton(final EmojiModel emoji) {
      void onPressed() {
        onChanged(emoji);
        List<EmojiModel> newLastEmojis = [...lastEmojis.value];
        final emojiExists = newLastEmojis.contains(emoji);
        if (!emojiExists) {
          newLastEmojis.insert(0, emoji);
        }
        if (newLastEmojis.length > maxItemsInRow && !emojiExists) {
          newLastEmojis = newLastEmojis.sublist(0, maxItemsInRow);
        }
        lastEmojis.value = newLastEmojis.toSet();
        context.read<LastEmojiStateNotifier>().assignEntries(
              newLastEmojis.map((final e) => MapEntry(e.emoji, e)),
            );
      }

      return EmojiButton(
        key: ValueKey(emoji),
        style: emojiStyle,
        emoji: emoji,
        onPressed: onPressed,
      );
    }

    return ButtonPopup(
      children: [
        Expanded(
          child: Consumer<EmojiStateNotifier>(
            builder: (final _, final provider, final __) {
              final emojis = provider.filteredValues;

              return GridView.count(
                restorationId: 'emojis-grid',
                shrinkWrap: true,
                crossAxisCount: maxItemsInRow,
                semanticChildCount: emojis.length,
                padding: const EdgeInsets.only(right: 12),
                children: emojis.map(buildEmojiButton).toList(),
              );
            },
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
              style: Theme.of(context).textTheme.titleSmall,
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
            padding: const EdgeInsets.all(8),
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
