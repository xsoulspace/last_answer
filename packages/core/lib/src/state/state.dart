import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_models/shared_models.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../core.dart';
import '../data_repositories/purchases_repository.dart';
import '../services/file_service/file_service_i.dart';
import 'logic/logic.dart';
import 'user_remote_initializer.dart';

export 'ads_notifier.dart';
export 'tags_notifier.dart';

part 'app_notifier.dart';
part 'emoji_state_notifier.dart';
part 'map_state_notifier.dart';
part 'notifications_notifier.dart';
part 'opened_project_notifier.dart';
part 'projects_notifier.dart';
part 'projects_paged_controller.dart';
part 'projects_paged_requests_builder.dart';
part 'purchases_notifier.dart';
part 'state.freezed.dart';
part 'user_local_initializer.dart';
part 'user_notifier.dart';
