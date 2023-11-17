import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data_models/data_models.dart';
import 'map_state_notifier.dart';

final class EmojiStateNotifier extends MapStateNotifier<EmojiModel> {
  EmojiStateNotifier({
    required final OnFilterCallback<EmojiModel> onFilter,
  }) : super(onFilter: onFilter);

  factory EmojiStateNotifier.provide() => EmojiStateNotifier(
        onFilter: (final emoji, final keyword) =>
            emoji.keywords.contains(keyword),
      );
}

final class LastEmojiStateNotifier extends MapStateNotifier<EmojiModel> {
  LastEmojiStateNotifier({
    required super.repository,
  });

  factory LastEmojiStateNotifier.provide(final BuildContext context) =>
      LastEmojiStateNotifier(
        repository: context.read(),
      );
}

final class SpecialEmojiStateNotifier extends MapStateNotifier<EmojiModel> {
  SpecialEmojiStateNotifier();
  factory SpecialEmojiStateNotifier.provide() => SpecialEmojiStateNotifier();
}
