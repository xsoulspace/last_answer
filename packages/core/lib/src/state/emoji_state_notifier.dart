// ignore_for_file: avoid_unused_constructor_parameters
part of 'state.dart';

final class EmojiStateNotifier extends MapStateNotifier<String, EmojiModel> {
  EmojiStateNotifier(final BuildContext context)
    : super(
        toKey: (final e) => e.emoji,
        onFilter: (final emoji, final keyword) =>
            keyword.isEmpty || emoji.keywords.contains(keyword),
      );
}

final class LastEmojiStateNotifier
    extends MapStateNotifier<String, EmojiModel> {
  LastEmojiStateNotifier(final BuildContext context)
    : lastUsedEmojiRepository = context.read(),
      super(toKey: (final e) => e.emoji);
  final LastUsedEmojiRepository lastUsedEmojiRepository;
}

final class SpecialEmojiStateNotifier
    extends MapStateNotifier<String, EmojiModel> {
  SpecialEmojiStateNotifier(final BuildContext context)
    : super(toKey: (final e) => e.emoji);
}
