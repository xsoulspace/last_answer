/// Legacy-kit port of the emoji helpers from
/// `_library/widgets/core/emoji_grid.dart` and
/// `_library/widgets/buttons/emoji_button.dart`.
///
/// The emoji data + insertion logic ([EmojiInserter], the recently-used
/// bookkeeping) is carried over VERBATIM; the presentation is rebuilt over
/// GridView + [LaPressable]/[LaButton]/[LaField] and the popup rides the
/// kit's [LaMenuAnchor] (the legacy `PopupButton`/`ButtonPopup` hover
/// portal is gone). Public API identical to the originals.
library;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lastanswer/common_imports.dart';

/// The emoji grid popup trigger (was `_library`'s `EmojiPopup`, riding
/// `PopupButton`). Closing the popup resets the search keyword, matching
/// the original's `onWebClose`.
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

    return LaMenuAnchor.builder(
      closeOnActivate: false,
      onOpenChange: (final isOpen) {
        if (!isOpen) context.read<EmojiStateNotifier>().filterKeyword = '';
      },
      entries: [LaMenuCustom(EmojiGrid(onChanged: emojiInserter.insert))],
      childBuilder: (final context, final anchor) => LaButton.icon(
        icon: const Icon(CupertinoIcons.smiley),
        onPressed: anchor.toggle,
      ),
    );
  }
}

class EmojiGrid extends HookWidget {
  const EmojiGrid({required this.onChanged, super.key});
  final ValueChanged<EmojiModel> onChanged;

  @override
  Widget build(final BuildContext context) {
    final emojiNotifier = context.watch<EmojiStateNotifier>();
    final lastEmojisNotifier = context.watch<LastEmojiStateNotifier>();
    final lastEmojis = lastEmojisNotifier.filteredValues;
    final filteredEmoji = emojiNotifier.filteredValues;
    final laUi = context.laUi;
    const maxItemsInRow = 9;
    final emojiStyle = PlatformInfo.isNativeDesktop && Platform.isMacOS
        ? null
        : laUi.body.copyWith(fontFamily: 'NotoColorEmoji');

    // The legacy `UiTextField` was value-driven off the notifier; the kit
    // field is controller-driven, so mirror the keyword into a controller.
    final keyword = emojiNotifier.filterKeyword;
    final searchController = useTextEditingController(text: keyword);
    useValueChanged<String, void>(keyword, (final _, final _) {
      if (searchController.text != keyword) searchController.text = keyword;
    });

    Widget buildEmojiButton(final EmojiModel emoji) => EmojiButton(
      key: ValueKey(emoji),
      style: emojiStyle,
      emoji: emoji,
      onPressed: () {
        onChanged(emoji);
        List<EmojiModel> newLastEmojis = [...lastEmojisNotifier.orderedValues];
        final emojiExists = newLastEmojis.contains(emoji);
        if (!emojiExists) {
          newLastEmojis.insert(0, emoji);
        }
        if (newLastEmojis.length > maxItemsInRow && !emojiExists) {
          newLastEmojis = newLastEmojis.sublist(0, maxItemsInRow);
        }
        lastEmojisNotifier.assignAllOrdered(newLastEmojis);
        context.read<LastEmojiStateNotifier>().upsertAll(newLastEmojis);
      },
    );

    return SizedBox(
      height: 320,
      width: !PlatformInfo.isNativeDesktop && !kIsWeb
          ? MediaQuery.of(context).size.width - 50
          : 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          LaHairline(color: laUi.rule),
          Visibility(
            visible: filteredEmoji.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 1, left: 9),
              child: Text(
                context.l10n.frequentlyUsed,
                style: laUi.emphasis,
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: LaField(
              controller: searchController,
              placeholder: context.l10n.search,
              onChanged: (final value) {
                emojiNotifier.filterKeyword = value;
              },
              suffix: LaButton.icon(
                size: LaButtonSize.sm,
                icon: const Icon(Icons.clear, size: 14),
                onPressed: () {
                  emojiNotifier.filterKeyword = '';
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable emoji cell (was the `_library` `EmojiButton`, a
/// CupertinoButton + MouseRegion). Same public API, kit press layer.
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
  Widget build(final BuildContext context) => LaPressable(
    onTap: onPressed,
    scaleOnPress: false,
    showRing: false,
    child: Center(child: Text(emoji.emoji, style: style)),
  );
}

/// One raised emoji key of the special-emoji keyboard (was the `_library`
/// `KeyboardEmojiButton`). Same public API, kit surfaces.
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
  Widget build(final BuildContext context) => LaPressable(
    onTap: onPressed,
    scaleOnPress: false,
    showRing: false,
    fill: context.laUi.fieldFill,
    radius: BorderRadius.circular(6),
    child: SizedBox(
      width: 35,
      height: 40,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: FittedBox(child: Text(emoji.emoji, style: style)),
      ),
    ),
  );
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
