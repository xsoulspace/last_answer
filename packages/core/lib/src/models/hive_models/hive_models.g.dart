// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectFolderAdapter extends TypeAdapter<ProjectFolder> {
  @override
  final int typeId = 9;

  @override
  ProjectFolder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectFolder(
      id: fields[0] as String,
      title: fields[1] as String,
      projectsIdsString: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectFolder obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.projectsIdsString);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectFolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emoji _$EmojiFromJson(Map<String, dynamic> json) => Emoji(
      category: json['category'] as String,
      emoji: json['emoji'] as String,
      keywords: json['keywords'] as String,
    );

Map<String, dynamic> _$EmojiToJson(Emoji instance) => <String, dynamic>{
      'category': instance.category,
      'emoji': instance.emoji,
      'keywords': instance.keywords,
    };

SerializableProjectId _$SerializableProjectIdFromJson(
        Map<String, dynamic> json) =>
    SerializableProjectId(
      id: json['id'] as String,
      type: $enumDecode(_$ProjectTypesEnumMap, json['type']),
    );

Map<String, dynamic> _$SerializableProjectIdToJson(
        SerializableProjectId instance) =>
    <String, dynamic>{
      'type': _$ProjectTypesEnumMap[instance.type]!,
      'id': instance.id,
    };

const _$ProjectTypesEnumMap = {
  ProjectTypes.idea: 'idea',
  ProjectTypes.note: 'note',
  ProjectTypes.story: 'story',
};
