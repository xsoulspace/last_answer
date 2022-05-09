part of abstract;

@immutable
@JsonSerializable()
class SupabaseError {
  const SupabaseError({
    required this.error,
    required this.errorDescription,
  });
  factory SupabaseError.fromJson(final Map<String, dynamic> json) =>
      _$SupabaseErrorFromJson(json);
  final String error;
  @JsonKey(name: 'error_description')
  final String errorDescription;
}
