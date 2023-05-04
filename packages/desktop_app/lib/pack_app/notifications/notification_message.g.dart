// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationMessage _$NotificationMessageFromJson(Map<String, dynamic> json) =>
    NotificationMessage(
      id: json['id'] as String,
      message: LocalizedText.fromJson(json['message'] as Map<String, dynamic>),
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      created: DateTime.parse(json['created'] as String),
    );
