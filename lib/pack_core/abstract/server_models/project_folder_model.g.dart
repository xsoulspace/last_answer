// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_folder_model.dart';

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
