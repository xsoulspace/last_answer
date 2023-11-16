import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import 'map_state.dart';

final class EmojiState extends MapState<EmojiModel> {
  EmojiState({
    required final OnFilterCallback<EmojiModel> onFilter,
  }) : super(onFilter: onFilter);
}

EmojiState createEmojiProvider(final BuildContext context) => EmojiState(
      onFilter: (final emoji, final keyword) =>
          emoji.keywords.contains(keyword),
    );

final class LastEmojiState extends MapState<EmojiModel> {
  LastEmojiState({
    required super.repository,
  });
}

LastEmojiState createLastUsedEmojisProvider(final BuildContext context) =>
    LastEmojiState(
      repository: context.read(),
    );

final class SpecialEmojiState extends MapState<EmojiModel> {}

SpecialEmojiState createSpecialEmojisProvider(final BuildContext context) =>
    SpecialEmojiState();
