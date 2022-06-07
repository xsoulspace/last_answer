import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/pack_core/pack_core.dart';

part 'serialazable_project_id.g.dart';

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

  final ProjectType type;
  final String id;
}
