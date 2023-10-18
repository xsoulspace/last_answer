// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteProjectAdapter extends TypeAdapter<NoteProject> {
  @override
  final int typeId = 6;

  @override
  NoteProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteProject(
      id: fields[0] as String,
      created: fields[3] as DateTime,
      updated: fields[4] as DateTime,
      folder: fields[6] as ProjectFolder?,
      note: fields[5] as String,
      isCompleted: fields[1] as bool,
      charactersLimit: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, NoteProject obj) {
    writer
      ..writeByte(7)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.folder)
      ..writeByte(7)
      ..write(obj.charactersLimit)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.updated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
