part of 'models.dart';

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class AppRouteParameters with _$AppRouteParameters {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory AppRouteParameters({
    @Default('') final String noteId,
    @Default('') final String ideaId,
    @Default('') final String answerId,
  }) = _AppRouteParameters;
  factory AppRouteParameters.fromJson(final Map<String, dynamic> json) =>
      _$AppRouteParametersFromJson(json);
}
