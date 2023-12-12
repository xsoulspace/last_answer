import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:shared_models/shared_models.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../core.dart';
import 'logic/logic.dart';

part 'app_notifier.dart';
part 'emoji_state_notifier.dart';
part 'map_state_notifier.dart';
part 'notifications_notifier.dart';
part 'opened_project_notifier.dart';
part 'projects_notifier.dart';
part 'projects_paged_controller.dart';
part 'projects_paged_requests_builder.dart';
part 'state.freezed.dart';
part 'user_initializer.dart';
part 'user_notifier.dart';
