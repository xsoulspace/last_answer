import 'package:lastanswer/data_emoji/data_emoji.dart';
import 'package:lastanswer/foundation/foundation.dart';
import 'package:material_ui/material_ui.dart' show BuildContext;
import 'package:provider/provider.dart';


final class EmojiStateNotifier extends MapStateNotifier<String, EmojiModel> {
  EmojiStateNotifier()
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
  SpecialEmojiStateNotifier()
    : super(toKey: (final e) => e.emoji);
}
