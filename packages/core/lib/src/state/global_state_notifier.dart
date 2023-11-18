import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../core.dart';
import 'projects_paged_requests_builder.dart';

part 'global_state_notifier.freezed.dart';

@freezed
class GlobalStateNotifierState with _$GlobalStateNotifierState {
  const factory GlobalStateNotifierState({
    @Default(RequestProjectsDto.empty)
    final RequestProjectsDto requestProjectsDto,
    @Default(UserModel.empty) final UserModel user,
    @Default(AppStateLoadingStatuses.settings)
    final AppStateLoadingStatuses appLoadingStatus,
  }) = _GlobalStateNotifierState;
}

class GlobalStateNotifierDto {
  GlobalStateNotifierDto(final BuildContext context)
      : projectsRepository = context.read(),
        userRepository = context.read();
  final ProjectsRepository projectsRepository;
  final UserRepository userRepository;
}

class GlobalStateNotifier extends ValueNotifier<GlobalStateNotifierState> {
  GlobalStateNotifier({
    required this.dto,
  }) : super(const GlobalStateNotifierState());

  factory GlobalStateNotifier.provide(final BuildContext context) =>
      GlobalStateNotifier(
        dto: GlobalStateNotifierDto(context),
      );
  final GlobalStateNotifierDto dto;
  late final ProjectsPagedController projectsPagedController =
      ProjectsPagedController(
    requestBuilder: ProjectsPagedDataRequestsBuilder.getAll(
      projectsRepository: dto.projectsRepository,
      getDto: () => value.requestProjectsDto,
    ),
  )..onLoad();
  List<IdeaProjectQuestionModel> get ideaQuestions => ideaQuestionsData;

  Future<void> onLoad() async {
    value = value.copyWith(user: await dto.userRepository.getUser());
  }

  void updateAppLoadingStatus(final AppStateLoadingStatuses status) =>
      setValue(value.copyWith(appLoadingStatus: status));

  void updateUser(final UserModel Function(UserModel) updateUser) =>
      setValue(value.copyWith(user: updateUser(value.user)));
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
