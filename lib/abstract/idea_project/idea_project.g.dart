// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaProjectAdapter extends TypeAdapter<IdeaProject> {
  @override
  final int typeId = 3;

  @override
  IdeaProject read(final BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProject(
      id: fields[0] as String,
      title: fields[2] as String,
      createdAt: fields[3] as DateTime,
      newAnswerText: fields[6] as String,
      folder: fields[8] as ProjectFolder?,
      newQuestion: fields[7] as IdeaProjectQuestion?,
      answers: (fields[5] as HiveList?)?.castHiveList(),
      isToDelete: fields[9] as bool?,
      updatedAt: fields[4] as DateTime?,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(final BinaryWriter writer, final IdeaProject obj) {
    writer
      ..writeByte(10)
      ..writeByte(5)
      ..write(obj.answers)
      ..writeByte(6)
      ..write(obj.newAnswerText)
      ..writeByte(7)
      ..write(obj.newQuestion)
      ..writeByte(8)
      ..write(obj.folder)
      ..writeByte(9)
      ..write(obj.isToDelete)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is IdeaProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
