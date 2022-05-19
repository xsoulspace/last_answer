library pack_settings;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_auth/pack_auth.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_note/pack_note.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_purchases_i/pack_purchases_i.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart';

part 'abstract/general_settings_controller.dart';
part 'abstract/general_settings_service.dart';
part 'features_widgets/characters_limit.dart';
part 'features_widgets/characters_limit_state.dart';
part 'features_widgets/general_settings.dart';
part 'features_widgets/locale_switcher_button.dart';
part 'features_widgets/my_account.dart';
part 'features_widgets/my_account_state.dart';
part 'features_widgets/settings_navigation.dart';
part 'features_widgets/theme_switcher_button.dart';
part 'pack_settings.freezed.dart';
part 'screens/desktop_settings_screen.dart';
part 'screens/general_settings_screen.dart';
part 'screens/my_account_screen.dart';
part 'screens/settings_navigation_screen.dart';
part 'screens/settings_screen.dart';
part 'screens/small_settings_screen.dart';
part 'screens/small_settings_screen_state.dart';
part 'screens/subscription_screen.dart';
part 'sync/models/instance_diff.dart';
part 'sync/models/instance_update_policy.dart';
part 'sync/models/model_updater_diff.dart';
part 'sync/models/remotely_updatable.dart';
part 'sync/updaters/folder_updater.dart';
part 'sync/updaters/idea_answer_updater.dart';
part 'sync/updaters/idea_question_updater.dart';
part 'sync/updaters/idea_updater.dart';
part 'sync/updaters/instance_updater.dart';
part 'sync/updaters/note_updater.dart';
part 'sync/updates_syncer.dart';
part 'widgets/settings_button.dart';
part 'widgets/settings_list_container.dart';
part 'widgets/settings_list_tile.dart';
part 'widgets/settings_text.dart';
