// GENERATED CODE - DO NOT MODIFY BY HAND

part of abstract;

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
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
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
      createdAt: fields[3] as DateTime,
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
      ..write(obj.createdAt);
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

class LocalizedTextAdapter extends TypeAdapter<LocalizedText> {
  @override
  final int typeId = 8;

  @override
  LocalizedText read(BinaryReader reader) {
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
  void write(BinaryWriter writer, LocalizedText obj) {
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizedTextAdapter &&
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
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
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
      createdAt: fields[3] as DateTime,
      folder: fields[5] as ProjectFolder?,
      isCompleted: fields[1] as bool,
    )..updatedAt = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, StoryProject obj) {
    writer
      ..writeByte(6)
      ..writeByte(5)
      ..write(obj.folder)
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ProjectFolderModel _$$_ProjectFolderModelFromJson(
        Map<String, dynamic> json) =>
    _$_ProjectFolderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ownerId: json['owner_id'] as String,
    );

Map<String, dynamic> _$$_ProjectFolderModelToJson(
        _$_ProjectFolderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'owner_id': instance.ownerId,
    };

_$_NoteProjectModel _$$_NoteProjectModelFromJson(Map<String, dynamic> json) =>
    _$_NoteProjectModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool,
      projectType: $enumDecode(_$ProjectTypeEnumMap, json['project_type']),
      userId: json['user_id'] as String,
      folderId: json['folder_id'] as String,
      charactersLimit: json['characters_limit'] as int?,
      note: json['note'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$_NoteProjectModelToJson(_$_NoteProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_completed': instance.isCompleted,
      'project_type': _$ProjectTypeEnumMap[instance.projectType],
      'user_id': instance.userId,
      'folder_id': instance.folderId,
      'characters_limit': instance.charactersLimit,
      'note': instance.note,
      'runtimeType': instance.$type,
    };

const _$ProjectTypeEnumMap = {
  ProjectType.idea: 'idea',
  ProjectType.note: 'note',
  ProjectType.story: 'story',
};

_$_IdeaProjectModel _$$_IdeaProjectModelFromJson(Map<String, dynamic> json) =>
    _$_IdeaProjectModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      projectType: $enumDecode(_$ProjectTypeEnumMap, json['project_type']),
      userId: json['user_id'] as String,
      folderId: json['folder_id'] as String,
      newAnswerText: json['new_answer_text'] as String,
      newQuestionId: json['new_question_id'] as String,
      title: json['title'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$_IdeaProjectModelToJson(_$_IdeaProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'project_type': _$ProjectTypeEnumMap[instance.projectType],
      'user_id': instance.userId,
      'folder_id': instance.folderId,
      'new_answer_text': instance.newAnswerText,
      'new_question_id': instance.newQuestionId,
      'title': instance.title,
      'runtimeType': instance.$type,
    };

_$_UserModel _$$_UserModelFromJson(Map<String, dynamic> json) => _$_UserModel(
      id: json['id'] as String,
    );

Map<String, dynamic> _$$_UserModelToJson(_$_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

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

LocalizedText _$LocalizedTextFromJson(Map<String, dynamic> json) =>
    LocalizedText(
      en: json['en'] as String,
      ru: json['ru'] as String,
      it: json['it'] as String?,
      ga: json['ga'] as String?,
    );

Map<String, dynamic> _$LocalizedTextToJson(LocalizedText instance) =>
    <String, dynamic>{
      'ru': instance.ru,
      'en': instance.en,
      'it': instance.it,
      'ga': instance.ga,
    };

SerializableProjectId _$SerializableProjectIdFromJson(
        Map<String, dynamic> json) =>
    SerializableProjectId(
      id: json['id'] as String,
      type: $enumDecode(_$ProjectTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$SerializableProjectIdToJson(
        SerializableProjectId instance) =>
    <String, dynamic>{
      'type': _$ProjectTypeEnumMap[instance.type],
      'id': instance.id,
    };

SupabaseError _$SupabaseErrorFromJson(Map<String, dynamic> json) =>
    SupabaseError(
      error: json['error'] as String,
      errorDescription: json['error_description'] as String,
    );

Map<String, dynamic> _$SupabaseErrorToJson(SupabaseError instance) =>
    <String, dynamic>{
      'error': instance.error,
      'error_description': instance.errorDescription,
    };
