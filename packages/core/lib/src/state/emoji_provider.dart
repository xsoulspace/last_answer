import 'package:flutter/cupertino.dart';

import '../models/models.dart';
import '../utils/utils.dart';
import 'map_state.dart';

class EmojiProvider extends MapState<Emoji> {
  EmojiProvider({
    required final OnFilterCallback<Emoji> onFilter,
  }) : super(onFilter: onFilter);
}

EmojiProvider createEmojiProvider(final BuildContext context) => EmojiProvider(
      onFilter: (final emoji, final keyword) =>
          emoji.keywords.contains(keyword),
    );

class LastEmojiProvider extends MapState<Emoji> {
  LastEmojiProvider({
    required super.saveUtil,
  });
}

LastEmojiProvider createLastUsedEmojisProvider(final BuildContext context) =>
    LastEmojiProvider(saveUtil: EmojiUtil());

class SpecialEmojiProvider extends MapState<Emoji> {}

SpecialEmojiProvider createSpecialEmojisProvider(final BuildContext context) =>
    SpecialEmojiProvider();
