// ignore_for_file: avoid_unused_constructor_parameters
part of 'state.dart';

final class EmojiStateNotifier extends MapStateNotifier<String, EmojiModel> {
  EmojiStateNotifier(final BuildContext context)
      : super(
          onFilter: (final emoji, final keyword) =>
              keyword.isEmpty || emoji.keywords.contains(keyword),
        );
}

final class LastEmojiStateNotifier
    extends MapStateNotifier<String, EmojiModel> {
  LastEmojiStateNotifier(final BuildContext context)
      : super(repository: context.read<LastUsedEmojiRepository>());
}

final class SpecialEmojiStateNotifier
    extends MapStateNotifier<String, EmojiModel> {
  SpecialEmojiStateNotifier(final BuildContext context);
}
