import 'dart:async';
import 'dart:convert' show JsonDecoder, Utf8Decoder;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:la_ui_kit/la_ui_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_state_utils/xsoulspace_state_utils.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';
import 'project_models.dart';
import 'projects_paged_requests_builder.dart';


final class ProjectsPagedController extends BasePagingController<ProjectModel> {
  ProjectsPagedController({required this.requestBuilder})
    : super(firstPageKey: 1);
  @override
  final ProjectsPagedDataRequestsBuilder requestBuilder;
}
