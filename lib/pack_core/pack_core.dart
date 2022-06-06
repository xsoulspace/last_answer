library pack_core;

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/abstract.dart';

part 'abstract/primitives/deletable.dart';
part 'abstract/primitives/has_id.dart';
part 'abstract/primitives/loadable.dart';
part 'abstract/primitives/remotely_available.dart';
part 'abstract/project_type.dart';
part 'abstract/server_models/idea_project_answer_model.dart';
part 'abstract/server_models/idea_project_question_model.dart';
part 'abstract/server_models/project_folder_model.dart';
part 'abstract/server_models/union_project_model.dart';
part 'abstract/server_models/user_model.dart';
part 'pack_core.freezed.dart';
part 'pack_core.g.dart';
part 'utils/connectivity_notifier.dart';
part 'utils/iterable_functions.dart';
