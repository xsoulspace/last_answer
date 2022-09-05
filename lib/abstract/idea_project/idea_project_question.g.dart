// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_project_question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaProjectQuestionAdapter extends TypeAdapter<IdeaProjectQuestion> {
  @override
  final int typeId = 5;

  @override
  IdeaProjectQuestion read(final BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProjectQuestion(
      id: fields[0] as dynamic,
      title: fields[1] as LocalizedText,
    );
  }

  @override
  void write(final BinaryWriter writer, final IdeaProjectQuestion obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is IdeaProjectQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdeaProjectQuestion _$IdeaProjectQuestionFromJson(
        final Map<String, dynamic> json) =>
    IdeaProjectQuestion(
      id: json['id'],
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      isToDelete: json['isToDelete'] as bool? ?? false,
    );

Map<String, dynamic> _$IdeaProjectQuestionToJson(
  final IdeaProjectQuestion instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isToDelete': instance.isToDelete,
    };
