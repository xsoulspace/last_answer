part of providers;

final emojiFilterProvider = StateProvider((final _) => '');

final emojisProvider =
    StateNotifierProvider<MapState<Emoji>, Map<String, Emoji>>(
  (final ref) => MapState<Emoji>(),
);

final filteredEmojisProvider = Provider((final ref) {
  final keyword = ref.watch(emojiFilterProvider).state;
  final emojis = ref.watch(emojisProvider);
  if (keyword.isEmpty) return emojis.values.toList();
  return emojis.values
      .where((final emoji) => emoji.keywords.contains(keyword))
      .toList();
});
