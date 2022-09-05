// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_folder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectFolderAdapter extends TypeAdapter<ProjectFolder> {
  @override
  final int typeId = 9;

  @override
  ProjectFolder read(final BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectFolder(
      id: fields[0] as dynamic,
      title: fields[1] as String,
      projectsIdsString: fields[2] as String,
      isToDelete: fields[3] as bool?,
      updatedAt: fields[4] as DateTime?,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(final BinaryWriter writer, final ProjectFolder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.projectsIdsString)
      ..writeByte(3)
      ..write(obj.isToDelete)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is ProjectFolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
