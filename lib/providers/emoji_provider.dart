part of providers;

final emojiFilterProvider = ''.inj();

final emojisProvider = MapState<Emoji>().inj(autoDisposeWhenNotUsed: false);

final filteredEmojisProvider = RM.inject<List<Emoji>>(
  () {
    final keyword = emojiFilterProvider.state;
    final emojis = emojisProvider.state.state.values;
    if (keyword.isEmpty) return emojis.toList();
    return emojis
        .where((final emoji) => emoji.keywords.contains(keyword))
        .toList();
  },
  dependsOn: DependsOn(
    {emojiFilterProvider},
    // Do not recalculate until 400 ms has passed without any
    // further notification from name injected model.
    debounceDelay: 400,
  ),
);

final lastUsedEmojisProvider = MapState<Emoji>(
  saveUtil: EmojiUtil(),
).inj(autoDisposeWhenNotUsed: false);

final specialEmojisProvider =
    MapState<Emoji>().inj(autoDisposeWhenNotUsed: false);
