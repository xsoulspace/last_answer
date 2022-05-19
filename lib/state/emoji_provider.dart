part of notifiers;

class EmojiProvider extends MapState<Emoji> {
  EmojiProvider({
    required final OnFilterCallback<Emoji> onFilter,
  }) : super(onFilter: onFilter);
}

EmojiProvider createEmojiProvider(final BuildContext context) {
  return EmojiProvider(
    onFilter: (final emoji, final keyword) => emoji.keywords.contains(keyword),
  );
}

class LastEmojiProvider extends MapState<Emoji> {
  LastEmojiProvider({
    required final SaveUtil<Emoji> saveUtil,
  }) : super(saveUtil: saveUtil);
}

LastEmojiProvider createLastUsedEmojisProvider(final BuildContext context) {
  return LastEmojiProvider(saveUtil: EmojiUtil());
}

class SpecialEmojiProvider extends MapState<Emoji> {}

SpecialEmojiProvider createSpecialEmojisProvider(final BuildContext context) {
  return SpecialEmojiProvider();
}
