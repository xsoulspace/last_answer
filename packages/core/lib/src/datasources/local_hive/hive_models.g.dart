// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaProjectAdapter extends TypeAdapter<IdeaProject> {
  @override
  final int typeId = 3;

  @override
  IdeaProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProject(
      id: fields[0] as String,
      title: fields[2] as String,
      created: fields[3] as DateTime,
      updated: fields[4] as DateTime,
      folder: fields[8] as ProjectFolder?,
      isCompleted: fields[1] as bool,
      newAnswerText: fields[6] as String,
      newQuestion: fields[7] as IdeaProjectQuestion?,
      answers: (fields[5] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProject obj) {
    writer
      ..writeByte(9)
      ..writeByte(5)
      ..write(obj.answers)
      ..writeByte(6)
      ..write(obj.newAnswerText)
      ..writeByte(7)
      ..write(obj.newQuestion)
      ..writeByte(8)
      ..write(obj.folder)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.updated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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

class IdeaProjectQuestionAdapter extends TypeAdapter<IdeaProjectQuestion> {
  @override
  final int typeId = 5;

  @override
  IdeaProjectQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaProjectQuestion(
      id: fields[0] as String,
      title: fields[1] as LocalizedText,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaProjectQuestion obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaProjectQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      created: fields[3] as DateTime,
      folder: fields[5] as ProjectFolder?,
      isCompleted: fields[1] as bool,
    )..updated = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, StoryProject obj) {
    writer
      ..writeByte(6)
      ..writeByte(5)
      ..write(obj.folder)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.updated);
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

IdeaProjectQuestion _$IdeaProjectQuestionFromJson(Map<String, dynamic> json) =>
    IdeaProjectQuestion(
      id: json['id'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IdeaProjectQuestionToJson(
        IdeaProjectQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
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
