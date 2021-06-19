import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lastanswer/abstract/locale_tile.dart';

part 'question.g.dart';

@JsonSerializable()
class Question extends Equatable {
  final LocaleTitle title;
  final String id;
  const Question({required this.title, required this.id});

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;
}
