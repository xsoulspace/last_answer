// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteUserModel _$RemoteUserModelFromJson(Map<String, dynamic> json) =>
    _RemoteUserModel(
      id: json['id'] == null
          ? UserModelId.empty
          : UserModelId.fromJson(json['id']),
    );

Map<String, dynamic> _$RemoteUserModelToJson(_RemoteUserModel instance) =>
    <String, dynamic>{'id': instance.id};
