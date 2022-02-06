part of pack_app;

@immutable
@JsonSerializable(createToJson: false, explicitToJson: true)
class NotificationMessage with EquatableMixin {
  const NotificationMessage({
    required this.id,
    required this.message,
    required this.title,
    required this.created,
  });
  factory NotificationMessage.fromJson(final Map<String, dynamic> json) =>
      _$NotificationMessageFromJson(json);

  final String id;
  final LocalizedText message;
  final LocalizedText title;
  final DateTime created;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [id];

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;
}