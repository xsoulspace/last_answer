part of 'dto.dart';

@freezed
class GetProjectsDto with _$GetProjectsDto {
  const factory GetProjectsDto({
    required final ProjectTypes type,
    @Default('') final String search,
  }) = _GetProjectsDto;
}
