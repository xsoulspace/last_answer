library abstract;

import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/providers/providers.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:mocktail/mocktail.dart';

part 'abstract.g.dart';
part 'basic_project.dart';
part 'basic_project_fields.dart';
part 'current_state_keys.dart';
part 'emoji.dart';
part 'greetings.dart';
part 'hive_boxes_ids.dart';
part 'idea_project/idea_project.dart';
part 'idea_project/idea_project_answer.dart';
part 'idea_project/idea_project_question.dart';
part 'loadable.dart';
part 'loading_statuses.dart';
part 'localization/language.dart';
part 'localization/localized_text.dart';
part 'localization/named_locale.dart';
part 'note_project/note_project.dart';
part 'project_folder.dart';
part 'project_types.dart';
part 'serialazable_project_id.dart';
part 'story_project/story_project.dart';
part 'typedefs.dart';
