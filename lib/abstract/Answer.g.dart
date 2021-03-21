// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Answer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnswerAdapter extends TypeAdapter<Answer> {
  @override
  final int typeId = 2;

  @override
  Answer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Answer(
      title: fields[0] as String,
      question: fields[1] as Question,
      id: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Answer obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
