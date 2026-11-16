/// The legacy-kit: functional helpers ported out of the demolished
/// `lib/_library/widgets/**` (ui-kit sweep lane D), rewritten widgets-layer
/// only and styled with `package:la_ui`. Button-like legacy widgets are NOT
/// ported — they map to kit components at the call site (see
/// docs/design/ui-kit-sweep-brief.md).
///
/// Each port keeps the original public API so consumer call sites only
/// change their import path.
library;

export 'dismissible_tile.dart';
export 'emoji.dart';
export 'faded_rail_page.dart';
export 'hero_id.dart';
export 'keyboard_visibility.dart';
export 'legacy_dialogs.dart';
export 'loadable_widget.dart';
export 'responsive.dart';
export 'right_scrollbar.dart';
export 'safe_areas.dart';
export 'scroll_keyboard_closer.dart';
export 'share_icon_button.dart';
export 'special_emoji.dart';
export 'unsplash.dart';
