// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_project_answer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaProjectAnswerAdapter extends TypeAdapter<IdeaProjectAnswer> {
  @override
  final int typeId = 4;

  @override
  IdeaProjectAnswer read(final BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProjectAnswer(
      id: fields[2] as String,
      text: fields[0] as String,
      question: fields[1] as IdeaProjectQuestion,
      createdAt: fields[3] as DateTime,
      projectId: fields[6] as String,
      isToDelete: fields[5] as bool,
      updatedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(final BinaryWriter writer, final IdeaProjectAnswer obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isToDelete)
      ..writeByte(6)
      ..write(obj.projectId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is IdeaProjectAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
