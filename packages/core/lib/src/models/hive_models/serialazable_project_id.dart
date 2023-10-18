part of 'hive_models.dart';

@immutable
@JsonSerializable()
class SerializableProjectId {
  const SerializableProjectId({
    required this.id,
    required this.type,
  });
  factory SerializableProjectId.fromJson(final Map<String, dynamic> json) =>
      _$SerializableProjectIdFromJson(json);
  Map<String, dynamic> toJson() => _$SerializableProjectIdToJson(this);

  final ProjectTypes type;
  final String id;
}
