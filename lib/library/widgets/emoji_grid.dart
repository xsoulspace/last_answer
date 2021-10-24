part of widgets;

class EmojiPopup extends HookWidget {
  const EmojiPopup({
    required final this.onChanged,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
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
        onChanged: onChanged,
        onClose: () => popupVisible.value = false,
      ),
      child: MouseRegion(
        onHover: (final _) => popupVisible.value = true,
        child: IconButton(
          onPressed: () => popupVisible.value = !popupVisible.value,
          icon: const Icon(Icons.emoji_emotions),
        ),
      ),
    );
  }
}

class EmojiGrid extends ConsumerWidget {
  const EmojiGrid({
    required final this.onChanged,
    required final this.onClose,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  final VoidCallback onClose;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final emojis = ref.read(emojisProvider);
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.cleanBlack
        : AppColors.grey4;
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
                    crossAxisCount: 6,
                    children: emojis.values
                        .map(
                          (final e) => TextButton(
                            key: ValueKey(e),
                            onPressed: () => onChanged(e),
                            child: Center(
                              child: Text(e.emoji),
                            ),
                          ),
                        )
                        .toList(),
                  ),
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
