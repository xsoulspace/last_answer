part of 'data_models.dart';

@freezed
class NotificationMessageModel with _$NotificationMessageModel {
  const factory NotificationMessageModel({
    required final String id,
    required final LocalizedTextModel message,
    required final LocalizedTextModel title,
    required final DateTime created,
  }) = _NotificationMessageModel;
  factory NotificationMessageModel.fromJson(final Map<String, dynamic> json) =>
      _$NotificationMessageModelFromJson(json);
}
