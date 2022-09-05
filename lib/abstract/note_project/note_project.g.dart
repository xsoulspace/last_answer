// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteProjectAdapter extends TypeAdapter<NoteProject> {
  @override
  final int typeId = 6;

  @override
  NoteProject read(final BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteProject(
      id: fields[0] as dynamic,
      createdAt: fields[3] as DateTime,
      note: fields[5] as String,
      folder: fields[6] as ProjectFolder?,
      charactersLimit: fields[7] as int?,
      isCompleted: fields[1] as bool,
      isToDelete: fields[8] as bool?,
      updatedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(final BinaryWriter writer, final NoteProject obj) {
    writer
      ..writeByte(8)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.folder)
      ..writeByte(7)
      ..write(obj.charactersLimit)
      ..writeByte(8)
      ..write(obj.isToDelete)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is NoteProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
