part of pack_app;

@immutable
@JsonSerializable(createToJson: false)
class NotificationMessage {
  const NotificationMessage({
    required this.id,
    required this.message,
    required this.created,
  });
  factory NotificationMessage.fromJson(final Map<String, dynamic> json) =>
      _$NotificationMessageFromJson(json);

  final String id;
  final String message;
  final DateTime created;
}
