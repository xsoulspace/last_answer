part of 'hive_models.dart';

@Deprecated('')
@immutable
@JsonSerializable()
class SerializableProjectId {
  @Deprecated('')
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
