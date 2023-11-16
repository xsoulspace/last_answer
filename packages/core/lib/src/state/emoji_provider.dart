import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import 'map_state.dart';

final class EmojiProvider extends MapState<EmojiModel> {
  EmojiProvider({
    required final OnFilterCallback<EmojiModel> onFilter,
  }) : super(onFilter: onFilter);
}

EmojiProvider createEmojiProvider(final BuildContext context) => EmojiProvider(
      onFilter: (final emoji, final keyword) =>
          emoji.keywords.contains(keyword),
    );

final class LastEmojiProvider extends MapState<EmojiModel> {
  LastEmojiProvider({
    required super.repository,
  });
}

LastEmojiProvider createLastUsedEmojisProvider(final BuildContext context) =>
    LastEmojiProvider(
      repository: context.read(),
    );

final class SpecialEmojiProvider extends MapState<EmojiModel> {}

SpecialEmojiProvider createSpecialEmojisProvider(final BuildContext context) =>
    SpecialEmojiProvider();
