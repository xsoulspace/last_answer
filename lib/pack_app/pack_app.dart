library pack_app;

import 'dart:async';
import 'dart:math' as math;

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_idea/pack_idea.dart';
import 'package:lastanswer/pack_note/note_screen.dart';
import 'package:lastanswer/pack_note/note_view.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

export 'screens/app_info.dart';
export 'screens/app_loading_screen.dart';
export 'screens/app_scaffold.dart';
export 'screens/app_state_provider.dart';
export 'screens/home/large_home_screen.dart';
export 'screens/home/projects_list_view.dart';
export 'screens/home/small_home_screen.dart';
export 'screens/home/vertical_projects_bar.dart';
export 'screens/unknown_screen.dart';

part 'navigator/app_navigator.dart';
part 'navigator/app_navigator_controller.dart';
part 'navigator/app_navigator_data_provider.dart';
part 'navigator/app_navigator_layout_builder.dart';
part 'navigator/app_navigator_page_builder.dart';
part 'navigator/app_navigator_pop_scope.dart';
part 'navigator/app_navigator_popper.dart';
part 'navigator/app_routes.dart';
part 'navigator/route_parameters.dart';
part 'notifications/update_notification_popup.dart';
part 'pack_app.g.dart';
part 'widgets/project_direction_switch.dart';
part 'widgets/project_text_field.dart';
part 'widgets/project_tile.dart';
part 'widgets/project_title_field.dart';
