library pack_app;

import 'dart:convert';

import 'package:blur/blur.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/generated/assets.gen.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_auth/pack_auth.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_note/pack_note.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_lib;
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

part 'navigator/app_navigator.dart';
part 'navigator/app_navigator_controller.dart';
part 'navigator/app_navigator_data_provider.dart';
part 'navigator/app_navigator_layout_builder.dart';
part 'navigator/app_navigator_page_builder.dart';
part 'navigator/app_navigator_pop_scope.dart';
part 'navigator/app_navigator_popper.dart';
part 'navigator/app_routes.dart';
part 'navigator/route_parameters.dart';
part 'notifications/notification_message.dart';
part 'notifications/notifications_controller.dart';
part 'notifications/notifications_service.dart';
part 'notifications/update_notification_dialog.dart';
part 'pack_app.g.dart';
part 'screens/app/app_scaffold.dart';
part 'screens/app/app_state_provider.dart';
part 'screens/app/last_answer_app.dart';
part 'screens/app_loading/app_loading_screen.dart';
part 'screens/home/large_home_screen.dart';
part 'screens/home/projects_list_view.dart';
part 'screens/home/small_home_screen.dart';
part 'screens/home/vertical_projects_bar.dart';
part 'screens/info/app_info.dart';
part 'screens/unknown/unknown_screen.dart';
part 'states/global_state_initializer.dart';
part 'states/global_state_notifiers.dart';
part 'widgets/project_direction_switch.dart';
part 'widgets/project_text_field.dart';
part 'widgets/project_tile.dart';
part 'widgets/project_title_field.dart';
