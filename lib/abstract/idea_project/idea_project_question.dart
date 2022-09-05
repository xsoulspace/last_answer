import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:lastanswer/abstract/hive_boxes_ids.dart';
import 'package:lastanswer/abstract/localization/localized_text.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/utils/utils.dart';

part 'idea_project_question.g.dart';

/// Use [IdeaProjectQuestion.fromTitle] to create class
/// This class immutable so in case of adding new properties make sure that it
/// will not broke immutabilty
@JsonSerializable()
@HiveType(typeId: HiveBoxesIds.ideaProjectQuestion)
class IdeaProjectQuestion
    extends RemoteHiveObjectWithId<IdeaProjectQuestionModel>
    with EquatableMixin
    implements Sharable {
  /// Do not use default constructor to create new [IdeaProjectQuestion]
  /// Do use [IdeaProjectQuestion.fromTitle]
  IdeaProjectQuestion({
    required this.id,
    required this.title,
    this.isToDelete = false,
  });
  factory IdeaProjectQuestion.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectQuestionFromJson(json);

  /// Use this function to create new [IdeaProjectQuestion]
  factory IdeaProjectQuestion.fromTitle(final LocalizedText title) =>
      IdeaProjectQuestion(id: createId(), title: title);
  @override
  @HiveField(0)
  final IdeaProjectQuestionId id;
  @HiveField(1)
  final LocalizedText title;

  @override
  bool isToDelete;

  Map<String, dynamic> toJson() => _$IdeaProjectQuestionToJson(this);

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;

  @override
  String toShareString(final BuildContext context) =>
      title.getByLanguage(Intl.getCurrentLocale());

  @override
  IdeaProjectQuestionModel toModel({required final UserModel user}) {
    return IdeaProjectQuestionModel(
      id: id,
      title: jsonEncode(title.toJson()),
    );
  }

  @override
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {
    await delete();
  }
}

/// A mock for [IdeaProjectQuestion].
/// To create use `final mockIdeaProjectQuestion = MockIdeaProjectQuestion();`
// ignore: avoid_implementing_value_types
// class MockIdeaProjectQuestion extends Mock implements IdeaProjectQuestion {}
