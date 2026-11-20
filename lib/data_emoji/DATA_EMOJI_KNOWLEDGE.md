# DATA_EMOJI_KNOWLEDGE.md

**Owns:** the emoji concern — the emoji catalog + last-used emoji data
sources, `EmojiRepository`, and the picker notifiers
(`EmojiStateNotifier`/`LastEmojiStateNotifier`/`SpecialEmojiStateNotifier`).

**How to extend:** catalog changes come from `assets/json/emojis.json`
(loaded through the repo); picker state is cold — provider-backed by law.
