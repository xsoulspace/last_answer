// ignore_for_file: avoid_unused_constructor_parameters
part of 'state.dart';

final class EmojiStateNotifier extends MapStateNotifier<EmojiModel> {
  EmojiStateNotifier({
    required final OnFilterCallback<EmojiModel> onFilter,
  }) : super(onFilter: onFilter);

  factory EmojiStateNotifier.provide(final BuildContext context) =>
      EmojiStateNotifier(
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
        repository: context.read<LastUsedEmojiRepository>(),
      );
}

final class SpecialEmojiStateNotifier extends MapStateNotifier<EmojiModel> {
  SpecialEmojiStateNotifier();
  factory SpecialEmojiStateNotifier.provide(final BuildContext context) =>
      SpecialEmojiStateNotifier();
}
