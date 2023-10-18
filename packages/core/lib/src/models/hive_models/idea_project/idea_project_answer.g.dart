// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_project_answer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaProjectAnswerAdapter extends TypeAdapter<IdeaProjectAnswer> {
  @override
  final int typeId = 4;

  @override
  IdeaProjectAnswer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProjectAnswer(
      text: fields[0] as String,
      question: fields[1] as IdeaProjectQuestion,
      id: fields[2] as String,
      created: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProjectAnswer obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaProjectAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
