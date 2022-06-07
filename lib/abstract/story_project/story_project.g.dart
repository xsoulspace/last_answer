// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryProjectAdapter extends TypeAdapter<StoryProject> {
  @override
  final int typeId = 7;

  @override
  StoryProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryProject(
      id: fields[0] as String,
      title: fields[2] as String,
      createdAt: fields[3] as DateTime,
      folder: fields[5] as ProjectFolder?,
      isToDelete: fields[6] as bool,
      updatedAt: fields[4] as DateTime?,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StoryProject obj) {
    writer
      ..writeByte(7)
      ..writeByte(5)
      ..write(obj.folder)
      ..writeByte(6)
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
