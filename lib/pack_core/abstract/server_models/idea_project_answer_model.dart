// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/pack_core/abstract/primitives/has_id.dart';
import 'package:lastanswer/pack_core/abstract/server_models/idea_project_question_model.dart';
import 'package:lastanswer/pack_core/abstract/server_models/user_model.dart';

part 'idea_project_answer_model.freezed.dart';
part 'idea_project_answer_model.g.dart';

typedef IdeaProjectAnswerId = String;
typedef IdeaProjectQuestionId = String;
typedef ProjectId = String;

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class IdeaProjectAnswerModel with _$IdeaProjectAnswerModel implements HasId {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory IdeaProjectAnswerModel({
    required final IdeaProjectAnswerId id,
    required final String text,
    @JsonKey(
      name: 'question_id',
      fromJson: fromIntToString,
      toJson: fromStringToInt,
    )
        required final IdeaProjectQuestionId questionId,
    @JsonKey(name: 'project_id')
        required final ProjectId projectId,
    @JsonKey(name: 'created_at')
        required final DateTime createdAt,
    @JsonKey(name: 'updated_at')
        required final DateTime updatedAt,
    @JsonKey(name: 'owner_id')
        required final UserModelId ownerId,
  }) = _IdeaProjectAnswerModel;
  factory IdeaProjectAnswerModel.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectAnswerModelFromJson(json);
  const IdeaProjectAnswerModel._();

  static Map<String, dynamic> modelToJson(final IdeaProjectAnswerModel model) =>
      model.toJson();
}
