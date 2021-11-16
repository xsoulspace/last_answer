part of widgets;

class SpecialEmojiPopup extends HookWidget {
  const SpecialEmojiPopup({
    required final this.controller,
    required final this.focusNode,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;

  bool? onPopupChange({
    required final BuildContext context,
    required final bool toOpen,
    required final ValueChanged<Emoji> onChanged,
    required final VoidCallback onClose,
  }) {
    if (!ScreenLayout.of(context).small) return null;
    if (toOpen) {
      final emojiGrid = SpecialEmojisGrid(
        onChanged: (final emoji) {
          onChanged(emoji);
          onClose();
        },
      );
      if (isAppleDevice) {
        showCupertinoDialog(
          context: context,
          builder: (final _) {
            return CupertinoAlertDialog(
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.current.close.titleCase),
                ),
              ],
              content: emojiGrid,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (final _) {
            return AlertDialog(
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    S.current.close.toUpperCase(),
                  ),
                ),
              ],
              content: emojiGrid,
            );
          },
        );
      }
    } else {
      Navigator.maybePop(context);
    }
    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final popupVisible = useIsBool();
    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
    );
    void onClose() => popupVisible.value = false;
    useValueChanged<bool, bool>(
      popupVisible.value,
      (final _, final __) => onPopupChange(
        context: context,
        toOpen: popupVisible.value,
        onChanged: emojiInserter.insert,
        onClose: onClose,
      ),
    );

    final screenLayout = ScreenLayout.of(context);
    if (screenLayout.small && !isDesktop) return const SizedBox();
    final emojiButton = IconButton(
      onPressed: () => popupVisible.value = true,
      icon: const Icon(Icons.emoji_flags_outlined),
    );
    if (ScreenLayout.of(context).small) {
      return emojiButton;
    }

    return PortalEntry(
      visible: popupVisible.value,
      portalAnchor:
          screenLayout.large ? Alignment.bottomLeft : Alignment.bottomRight,
      childAnchor: screenLayout.large ? Alignment.topRight : Alignment.topLeft,
      portal: MouseRegion(
        onExit: (final _) => onClose(),
        child: SpecialEmojisGrid(
          onChanged: emojiInserter.insert,
        ),
      ),
      child: MouseRegion(
        onHover: (final _) => popupVisible.value = true,
        child: emojiButton,
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
      height: 80,
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
