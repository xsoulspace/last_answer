import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../core.dart';
import 'projects_paged_requests_builder.dart';

part 'projects_notifier.freezed.dart';

@freezed
class ProjectsNotifierState with _$ProjectsNotifierState {
  const factory ProjectsNotifierState({
    @Default(RequestProjectsDto.empty)
    final RequestProjectsDto requestProjectsDto,
  }) = _ProjectsNotifierState;
}

class ProjectsNotifierDto {
  ProjectsNotifierDto(final BuildContext context)
      : projectsRepository = context.read();
  final ProjectsRepository projectsRepository;
}

class ProjectsNotifier extends ValueNotifier<ProjectsNotifierState> {
  ProjectsNotifier({
    required this.dto,
  }) : super(const ProjectsNotifierState());

  factory ProjectsNotifier.provide(final BuildContext context) =>
      ProjectsNotifier(
        dto: ProjectsNotifierDto(context),
      );
  final ProjectsNotifierDto dto;
  late final ProjectsPagedController projectsPagedController =
      ProjectsPagedController(
    requestBuilder: ProjectsPagedDataRequestsBuilder.getAll(
      projectsRepository: dto.projectsRepository,
      getDto: () => value.requestProjectsDto,
    ),
  )..onLoad();
  List<IdeaProjectQuestionModel> get ideaQuestions => ideaQuestionsData;

  Future<void> onLoad() async {
    projectsPagedController.loadFirstPage();
  }

  void onReset() {
    projectsPagedController.refresh();
  }

  void updateProject(final ProjectModel project) =>
      _projectsUpdatesController.add(project);

  late final _projectsUpdatesController = StreamController<ProjectModel>()
    ..stream.sampleTime(1.seconds).listen(_updateProject);
  void _updateProject(final ProjectModel project) =>
      projectsPagedController.pager.replaceElement(
        element: project,
        equals: (final e, final e2) => e.id == e2.id,
        shouldAddOnNotFound: true,
      );

  @override
  void dispose() {
    unawaited(_projectsUpdatesController.close());
    projectsPagedController.dispose();
    super.dispose();
  }
}
