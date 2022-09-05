// ignore_for_file: invalid_annotation_target

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/abstract/primitives/has_id.dart';
import 'package:lastanswer/pack_core/abstract/server_models/idea_project_answer_model.dart';

part 'idea_project_question_model.freezed.dart';
part 'idea_project_question_model.g.dart';

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class IdeaProjectQuestionModel
    with _$IdeaProjectQuestionModel
    implements HasId {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory IdeaProjectQuestionModel({
    @JsonKey(
      fromJson: fromIntToString,
      toJson: fromStringToInt,
    )
        required final IdeaProjectQuestionId id,
    required final String title,
  }) = _IdeaProjectQuestionModel;
  const IdeaProjectQuestionModel._();
  factory IdeaProjectQuestionModel.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectQuestionModelFromJson(json);
  static Map<String, dynamic> modelToJson(
    final IdeaProjectQuestionModel model,
  ) =>
      model.toJson();
  LocalizedText get localizedTitle => LocalizedText.fromJson(jsonDecode(title));
}

int fromStringToInt(final String value) => int.parse(value);
String fromIntToString(final int value) => '$value';