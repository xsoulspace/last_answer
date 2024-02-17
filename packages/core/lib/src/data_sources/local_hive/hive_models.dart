import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

export 'localization/localization.dart';

part 'basic_project.dart';
part 'basic_project_fields.dart';
part 'current_state_keys.dart';
part 'has_id.dart';
part 'hive_boxes_ids.dart';
part 'hive_models.g.dart';
part 'idea_project/idea_project.dart';
part 'idea_project/idea_project_answer.dart';
part 'idea_project/idea_project_question.dart';
part 'note_project.dart';
part 'project_folder.dart';
part 'project_types.dart';
part 'serialazable_project_id.dart';
