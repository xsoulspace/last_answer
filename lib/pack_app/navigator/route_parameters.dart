part of pack_app;

@immutable
@JsonSerializable()
class AppRouteParameters {
  const AppRouteParameters({
    this.noteId,
    this.ideaId,
    this.answerId,
  });
  factory AppRouteParameters.fromJson(final Map<String, dynamic> json) =>
      _$AppRouteParametersFromJson(json);
  final String? noteId;
  final String? ideaId;
  final String? answerId;
}
