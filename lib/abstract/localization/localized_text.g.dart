// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localized_text.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalizedTextAdapter extends TypeAdapter<LocalizedText> {
  @override
  final int typeId = 8;

  @override
  LocalizedText read(final BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalizedText(
      en: fields[1] as String,
      ru: fields[0] as String,
      it: fields[2] as String?,
      ga: fields[3] as String?,
    );
  }

  @override
  void write(final BinaryWriter writer, final LocalizedText obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ru)
      ..writeByte(1)
      ..write(obj.en)
      ..writeByte(2)
      ..write(obj.it)
      ..writeByte(3)
      ..write(obj.ga);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is LocalizedTextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalizedText _$LocalizedTextFromJson(final Map<String, dynamic> json) =>
    LocalizedText(
      en: json['en'] as String,
      ru: json['ru'] as String,
      it: json['it'] as String?,
      ga: json['ga'] as String?,
    );

Map<String, dynamic> _$LocalizedTextToJson(final LocalizedText instance) =>
    <String, dynamic>{
      'ru': instance.ru,
      'en': instance.en,
      'it': instance.it,
      'ga': instance.ga,
    };
