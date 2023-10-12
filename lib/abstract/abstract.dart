library abstract;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/abstract/localization/localized_text.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';

export 'idea_project/idea_project.dart';
export 'localization/localization.dart';
export 'note_project/note_project.dart';
export 'story_project/story_project.dart';

part 'abstract.g.dart';
part 'basic_project.dart';
part 'basic_project_fields.dart';
part 'current_state_keys.dart';
part 'emoji.dart';
part 'greetings.dart';
part 'has_id.dart';
part 'hive_boxes_ids.dart';
part 'loadable.dart';
part 'loading_statuses.dart';
part 'project_folder.dart';
part 'project_types.dart';
part 'serialazable_project_id.dart';
part 'typedefs.dart';
