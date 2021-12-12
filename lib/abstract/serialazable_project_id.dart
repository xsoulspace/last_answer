part of abstract;

@immutable
@JsonSerializable()
class SerializableProjectId {
  const SerializableProjectId({
    required final this.id,
    required final this.type,
  });
  factory SerializableProjectId.fromJson(final Map<String, dynamic> json) =>
      _$SerializableProjectIdFromJson(json);
  Map<String, dynamic> toJson() => _$SerializableProjectIdToJson(this);

  final ProjectTypes type;
  final String id;
}
