// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AppSettingsModel _$$_AppSettingsModelFromJson(Map<String, dynamic> json) =>
    _$_AppSettingsModel(
      locale: localeFromString(json['locale'] as String?),
    );

Map<String, dynamic> _$$_AppSettingsModelToJson(_$_AppSettingsModel instance) =>
    <String, dynamic>{
      'locale': localeToString(instance.locale),
    };

_$_ProjectModelId _$$_ProjectModelIdFromJson(Map<String, dynamic> json) =>
    _$_ProjectModelId(
      value: json['value'] as String,
    );

Map<String, dynamic> _$$_ProjectModelIdToJson(_$_ProjectModelId instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

_$NoteProjectModel _$$NoteProjectModelFromJson(Map<String, dynamic> json) =>
    _$NoteProjectModel(
      id: ProjectModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: json['is_archived'] as bool,
      type: $enumDecode(_$ProjectTypeEnumMap, json['type']),
      ownerId: UserModelId.fromJson(json['owner_id'] as String),
      charactersLimit: json['characters_limit'] as int?,
      note: DeltaModel.fromJson(json['note'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$NoteProjectModelToJson(_$NoteProjectModel instance) =>
    <String, dynamic>{
      'id': ProjectModelId.toStringJson(instance.id),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_archived': instance.isArchived,
      'type': _$ProjectTypeEnumMap[instance.type]!,
      'owner_id': instance.ownerId.toJson(),
      'characters_limit': instance.charactersLimit,
      'note': instance.note.toJson(),
    };

const _$ProjectTypeEnumMap = {
  ProjectType.note: 'NoteProjectModel',
  ProjectType.idea: 'IdeaProjectModel',
  ProjectType.story: 'StoryProjectModel',
};

_$_DeltaModel _$$_DeltaModelFromJson(Map<String, dynamic> json) =>
    _$_DeltaModel(
      value: DeltaModel._deltaFromJson(json['value'] as String),
    );

Map<String, dynamic> _$$_DeltaModelToJson(_$_DeltaModel instance) =>
    <String, dynamic>{
      'value': DeltaModel._deltaToJson(instance.value),
    };

_$_UserModelId _$$_UserModelIdFromJson(Map<String, dynamic> json) =>
    _$_UserModelId(
      value: json['value'] as String,
    );

Map<String, dynamic> _$$_UserModelIdToJson(_$_UserModelId instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

_$_UserModel _$$_UserModelFromJson(Map<String, dynamic> json) => _$_UserModel(
      id: UserModelId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subscription: SubscriptionModel.fromJson(
          json['subscription'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_UserModelToJson(_$_UserModel instance) =>
    <String, dynamic>{
      'id': UserModelId.toStringJson(instance.id),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'subscription': instance.subscription.toJson(),
    };

_$_SubscriptionModel _$$_SubscriptionModelFromJson(Map<String, dynamic> json) =>
    _$_SubscriptionModel(
      paidDaysLeft: json['paid_days_left'] as int? ?? 0,
    );

Map<String, dynamic> _$$_SubscriptionModelToJson(
        _$_SubscriptionModel instance) =>
    <String, dynamic>{
      'paid_days_left': instance.paidDaysLeft,
    };

_$_UserPermissionsModel _$$_UserPermissionsModelFromJson(
        Map<String, dynamic> json) =>
    _$_UserPermissionsModel(
      shouldBeSynced: json['should_be_synced'] as bool? ?? false,
      tagLimit: json['tag_limit'] as int? ?? 5,
    );

Map<String, dynamic> _$$_UserPermissionsModelToJson(
        _$_UserPermissionsModel instance) =>
    <String, dynamic>{
      'should_be_synced': instance.shouldBeSynced,
      'tag_limit': instance.tagLimit,
    };
