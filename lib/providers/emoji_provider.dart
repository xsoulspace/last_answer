part of providers;

final emojisProvider =
    StateNotifierProvider<MapState<Emoji>, Map<String, Emoji>>(
  (final _) => MapState<Emoji>(),
);
