// GENERATED CODE - DO NOT MODIFY BY HAND

part of pack_core;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_IdeaProjectAnswerModel _$$_IdeaProjectAnswerModelFromJson(
        Map<String, dynamic> json) =>
    _$_IdeaProjectAnswerModel(
      id: json['id'] as String,
      text: json['text'] as String,
      questionId: fromIntToString(json['question_id'] as int),
      projectId: json['project_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ownerId: json['owner_id'] as String,
    );

Map<String, dynamic> _$$_IdeaProjectAnswerModelToJson(
        _$_IdeaProjectAnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'question_id': fromStringToInt(instance.questionId),
      'project_id': instance.projectId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'owner_id': instance.ownerId,
    };

_$_IdeaProjectQuestionModel _$$_IdeaProjectQuestionModelFromJson(
        Map<String, dynamic> json) =>
    _$_IdeaProjectQuestionModel(
      id: fromIntToString(json['id'] as int),
      title: json['title'] as String,
    );

Map<String, dynamic> _$$_IdeaProjectQuestionModelToJson(
        _$_IdeaProjectQuestionModel instance) =>
    <String, dynamic>{
      'id': fromStringToInt(instance.id),
      'title': instance.title,
    };

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

_$NoteProjectModel _$$NoteProjectModelFromJson(Map<String, dynamic> json) =>
    _$NoteProjectModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool,
      projectType: $enumDecode(_$ProjectTypeEnumMap, json['project_type']),
      userId: json['user_id'] as String,
      folderId: json['folder_id'] as String,
      charactersLimit: json['characters_limit'] as int?,
      note: json['note'] as String,
      $type: json['runtime_type'] as String?,
    );

Map<String, dynamic> _$$NoteProjectModelToJson(_$NoteProjectModel instance) =>
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
      'runtime_type': instance.$type,
    };

const _$ProjectTypeEnumMap = {
  ProjectType.idea: 'idea',
  ProjectType.note: 'note',
  ProjectType.story: 'story',
};

_$IdeaProjectModel _$$IdeaProjectModelFromJson(Map<String, dynamic> json) =>
    _$IdeaProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool,
      projectType: $enumDecode(_$ProjectTypeEnumMap, json['project_type']),
      userId: json['user_id'] as String,
      folderId: json['folder_id'] as String,
      newAnswerText: json['new_answer_text'] as String,
      newQuestionId: json['new_question_id'] as String?,
      $type: json['runtime_type'] as String?,
    );

Map<String, dynamic> _$$IdeaProjectModelToJson(_$IdeaProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_completed': instance.isCompleted,
      'project_type': _$ProjectTypeEnumMap[instance.projectType],
      'user_id': instance.userId,
      'folder_id': instance.folderId,
      'new_answer_text': instance.newAnswerText,
      'new_question_id': instance.newQuestionId,
      'runtime_type': instance.$type,
    };

_$_UserModel _$$_UserModelFromJson(Map<String, dynamic> json) => _$_UserModel(
      id: json['id'] as String,
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      username: json['username'] as String,
    );

Map<String, dynamic> _$$_UserModelToJson(_$_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$UserStatusEnumMap[instance.status],
      'username': instance.username,
    };

const _$UserStatusEnumMap = {
  UserStatus.online: 'online',
  UserStatus.offline: 'offline',
};
