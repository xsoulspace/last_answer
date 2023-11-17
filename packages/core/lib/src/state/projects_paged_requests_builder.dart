import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core.dart';

part 'projects_paged_requests_builder.freezed.dart';

@freezed
class RequestProjectsDto with _$RequestProjectsDto {
  const factory RequestProjectsDto({
    @Default('') final String search,
    @Default([]) final List<ProjectTypes> types,
  }) = _RequestProjectsDto;
  static const empty = RequestProjectsDto();
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
