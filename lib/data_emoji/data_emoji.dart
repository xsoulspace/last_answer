/// The emoji data concern: emoji catalog + last-used emoji data sources,
/// the emoji repository, and the emoji picker state. See
/// DATA_EMOJI_KNOWLEDGE.md.
library;

export 'data_sources/interfaces/emoji.dart';
export 'data_sources/local/emoji.dart';
export 'data_sources/local/last_used_emoji.dart';
export 'emoji_models.dart';
export 'emoji_repository.dart';
export 'emoji_state_notifier.dart';
