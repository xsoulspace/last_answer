library widgets;

import 'dart:math' as math;

import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart' as slidable;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/gen/assets.gen.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/hooks/hooks.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/providers/providers.dart';
import 'package:lastanswer/screens/home/home.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:recase/recase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

part 'button_popup.dart';
part 'choosable_bubble.dart';
part 'circular_loader.dart';
part 'dismissible_tile.dart';
part 'editable_bubble.dart';
part 'emoji_button.dart';
part 'emoji_grid.dart';
part 'focus_bubble_container.dart';
part 'hero_id.dart';
part 'icon_add_button.dart';
part 'icon_apply_button.dart';
part 'icon_close_button.dart';
part 'icon_expand_button.dart';
part 'icon_hide_button.dart';
part 'icon_idea_button.dart';
part 'icon_info_button.dart';
part 'icon_note_button.dart';
part 'icon_select_button.dart';
part 'icon_settings_button.dart';
part 'icon_share_button.dart';
part 'icon_story_button.dart';
part 'icon_submit_button.dart';
part 'macos_appbar.dart';
part 'note_tile.dart';
part 'project_text_field.dart';
part 'project_tile.dart';
part 'project_title_field.dart';
part 'remove_title_dialog.dart';
part 'responsive_widget.dart';
part 'safe_areas.dart';
part 'scroll_keyboard_closer.dart';
part 'special_emoji_grid.dart';
part 'svg_icon_button.dart';
