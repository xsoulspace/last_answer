part of widgets;

class SpecialEmojiPopup extends HookWidget {
  const SpecialEmojiPopup({
    required final this.controller,
    required final this.focusNode,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;

  bool? onOpenPopup({
    required final BuildContext context,
    required final ValueChanged<Emoji> onChanged,
    required final VoidCallback onClose,
  }) {
    if (isDesktop) return null;
    void close(final BuildContext context) {
      onClose();
      Navigator.maybePop(context);
    }

    Widget buildEmojiGrid(final BuildContext context) => SpecialEmojisGrid(
          onChanged: onChanged,
          hideBorder: true,
        );
    if (isAppleDevice) {
      showCupertinoDialog(
        context: context,
        builder: (final context) {
          return CupertinoAlertDialog(
            actions: [
              CupertinoDialogAction(
                onPressed: () => close(context),
                child: Text(S.current.close.titleCase),
              ),
            ],
            content: buildEmojiGrid(context),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (final context) {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () => close(context),
                child: Text(
                  S.current.close.toUpperCase(),
                ),
              ),
            ],
            content: buildEmojiGrid(context),
          );
        },
      );
    }

    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final popupVisible = useIsBool();
    final popupHovered = useIsBool();
    final screenLayout = ScreenLayout.of(context);
    final emojiInserter = EmojiInserter.use(
      controller: controller,
      focusNode: focusNode,
    );
    Future<void> onClose() async {
      await Future.delayed(const Duration(milliseconds: 300), () {
        if (popupHovered.value) return;
        popupVisible.value = false;
      });
    }

    useValueChanged<bool, bool>(
      popupVisible.value,
      (final _, final __) {
        if (!popupVisible.value) return;
        WidgetsBinding.instance?.addPostFrameCallback((final _) {
          onOpenPopup(
            context: context,
            onChanged: emojiInserter.insert,
            onClose: () => popupVisible.value = false,
          );
        });
      },
    );

    final emojiButton = IconButton(
      onPressed: () => popupVisible.value = true,
      icon: const Icon(Icons.emoji_flags_outlined),
    );
    if (!isDesktop) return emojiButton;
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
        child: SpecialEmojisGrid(
          onChanged: emojiInserter.insert,
        ),
      ),
      child: MouseRegion(
        onHover: (final _) {
          popupVisible.value = true;
        },
        onExit: (final _) async => onClose(),
        child: emojiButton,
      ),
    );
  }
}

class SpecialEmojisGrid extends StatelessWidget {
  const SpecialEmojisGrid({
    required final this.onChanged,
    final this.hideBorder = false,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  final bool hideBorder;
  @override
  Widget build(final BuildContext context) {
    Widget buildEmojiButton(final Emoji emoji) {
      return EmojiButton(
        key: ValueKey(emoji),
        emoji: emoji,
        onPressed: () => onChanged(emoji),
      );
    }

    final specialEmojisProvider = context.read<SpecialEmojiProvider>();
    final emojis = specialEmojisProvider.values;
    const maxItemsInRow = 9;

    return ButtonPopup(
      height: 80,
      hideBorder: hideBorder,
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
