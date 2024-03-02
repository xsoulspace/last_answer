part of 'state.dart';

@freezed
class RequestProjectsDto with _$RequestProjectsDto {
  const factory RequestProjectsDto({
    @Default('') final String search,
    @Default([]) final List<ProjectTypes> types,
    @Default(false) final bool isReversed,
    @Default(ProjectTagModelId.empty) final ProjectTagModelId tagId,
  }) = _RequestProjectsDto;
  const RequestProjectsDto._();
  static const empty = RequestProjectsDto();
  bool get isEmpty => search.isEmpty && types.isEmpty && tagId.isEmpty;
}

class ProjectsPagedDataRequestsBuilder
    extends PagedRequestsBuilder<ProjectModel> {
  ProjectsPagedDataRequestsBuilder({
    required super.onLoadData,
  });
  factory ProjectsPagedDataRequestsBuilder.getAll({
    required final ProjectsRepository projectsRepository,
    required final ValueGetter<RequestProjectsDto> getDto,
  }) =>
      ProjectsPagedDataRequestsBuilder(
        onLoadData: (final pageKey) async => projectsRepository.getPaginated(
          request: PaginatedPageRequestModel(
            data: getDto(),
            page: pageKey,
          ),
        ),
      );
}
