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

_$NoteProjectModel _$$NoteProjectModelFromJson(Map<String, dynamic> json) =>
    _$NoteProjectModel(
      remoteId: ProjectModelId.remoteFromJson(json['remote_id'] as String),
      localId: ProjectModelId.localFromJson(json['local_id'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: json['is_archived'] as bool,
      type: $enumDecode(_$ProjectTypeEnumMap, json['type']),
      ownerId: UserModelId.remoteFromJson(json['owner_id'] as String),
      charactersLimit: json['characters_limit'] as int?,
      note: DeltaModel.fromJson(json['note'] as Map<String, dynamic>),
      isDeleted: json['is_deleted'] as bool? ?? false,
      daysBeforeDeletion: json['days_before_deletion'] as int? ?? 30,
    );

Map<String, dynamic> _$$NoteProjectModelToJson(_$NoteProjectModel instance) =>
    <String, dynamic>{
      'remote_id': ProjectModelId.toStringJson(instance.remoteId),
      'local_id': ProjectModelId.toStringJson(instance.localId),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_archived': instance.isArchived,
      'type': _$ProjectTypeEnumMap[instance.type]!,
      'owner_id': UserModelId.toStringJson(instance.ownerId),
      'characters_limit': instance.charactersLimit,
      'note': instance.note.toJson(),
      'is_deleted': instance.isDeleted,
      'days_before_deletion': instance.daysBeforeDeletion,
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

_$_UserModel _$$_UserModelFromJson(Map<String, dynamic> json) => _$_UserModel(
      localId: UserModelId.localFromJson(json['local_id'] as String),
      remoteId: UserModelId.remoteFromJson(json['remote_id'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subscription: SubscriptionModel.fromJson(
          json['subscription'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_UserModelToJson(_$_UserModel instance) =>
    <String, dynamic>{
      'local_id': UserModelId.toStringJson(instance.localId),
      'remote_id': UserModelId.toStringJson(instance.remoteId),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'subscription': instance.subscription.toJson(),
    };

_$_SubscriptionModel _$$_SubscriptionModelFromJson(Map<String, dynamic> json) =>
    _$_SubscriptionModel(
      paidDaysLeft: json['paid_days_left'] as int? ?? 0,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$_SubscriptionModelToJson(
        _$_SubscriptionModel instance) =>
    <String, dynamic>{
      'paid_days_left': instance.paidDaysLeft,
      'updated_at': instance.updatedAt?.toIso8601String(),
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
