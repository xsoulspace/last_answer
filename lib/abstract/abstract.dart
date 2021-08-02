library abstract;

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:mocktail/mocktail.dart';

part 'abstract.g.dart';
part 'basic_project.dart';
part 'current_state_keys.dart';
part 'deprecated/answer.dart';
part 'deprecated/project.dart';
part 'deprecated/question.dart';
part 'hive_boxes_ids.dart';
part 'idea_project/idea_project.dart';
part 'idea_project/idea_project_answer.dart';
part 'idea_project/idea_project_question.dart';
part 'localization/language.dart';
part 'localization/localized_text.dart';
part 'localization/named_locale.dart';
part 'note_project/note_project.dart';
part 'story_project/story_project.dart';