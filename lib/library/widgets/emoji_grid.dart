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
    if (screenLayout.small) return const SizedBox();
    return PortalEntry(
      visible: popupVisible.value,
      portalAnchor:
          screenLayout.large ? Alignment.bottomLeft : Alignment.bottomRight,
      childAnchor: screenLayout.large ? Alignment.topRight : Alignment.topLeft,
      portal: EmojiGrid(onChanged: onChanged),
      child: IconButton(
        onPressed: () => popupVisible.value = !popupVisible.value,
        icon: const Icon(Icons.emoji_emotions),
      ),
    );
  }
}

class EmojiGrid extends ConsumerWidget {
  const EmojiGrid({
    required final this.onChanged,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Emoji> onChanged;
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final emojis = ref.read(emojisProvider);

    return Card(
      child: SizedBox(
        height: 400,
        width: 200,
        child: GridView.count(
          crossAxisCount: 5,
          children: emojis.values
              .map(
                (final e) => TextButton(
                  onPressed: () => onChanged(e),
                  child: Center(
                    child: Text(e.emoji),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
