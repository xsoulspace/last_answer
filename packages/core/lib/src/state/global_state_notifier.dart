import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:provider/provider.dart';

import '../../core.dart';
import 'projects_paged_controller.dart';
import 'projects_paged_requests_builder.dart';

part 'global_state_notifier.freezed.dart';

class GlobalStateNotifiers {
  GlobalStateNotifiers._();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  static final settings =
      GeneralSettingsController(settingsService: SettingsService());
}

@freezed
class GlobalStateNotifierState with _$GlobalStateNotifierState {
  const factory GlobalStateNotifierState({
    @Default({})
    final Map<String, IdeaProjectQuestionModel> ideaProjectQuestions,
    @Default(RequestProjectsDto.empty)
    final RequestProjectsDto requestProjectsDto,
  }) = _GlobalStateNotifierState;
}

class GlobalStateNotifierDto {
  GlobalStateNotifierDto(final BuildContext context)
      : projectsRepository = context.read();
  final ProjectsRepository projectsRepository;
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

  @override
  void dispose() {
    projectsPagedController.dispose();
    super.dispose();
  }
}
