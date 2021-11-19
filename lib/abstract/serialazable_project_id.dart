part of abstract;

@immutable
@JsonSerializable()
class SerializableProjectId {
  const SerializableProjectId({
    required final this.id,
    required final this.type,
  });
  final ProjectTypes type;
  final String id;

  static SerializableProjectId fromJson(final Map<String, dynamic> json) =>
      _$SerializableProjectIdFromJson(json);
}
