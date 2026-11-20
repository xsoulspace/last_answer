import 'dart:async';
import 'dart:convert' show JsonDecoder, Utf8Decoder;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:la_ui_kit/la_ui_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_state_utils/xsoulspace_state_utils.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';
import 'package:lastanswer/data_projects/data_projects.dart';
import 'package:lastanswer/foundation/foundation.dart';
import 'package:la_locale/la_locale.dart';

part 'app_notifier.freezed.dart';

enum AppStatus { offline, online, loading }

@freezed
abstract class AppFeaturesModel with _$AppFeaturesModel {
  const factory AppFeaturesModel({
    @Default(false) final bool isRemoteServicesEnabled,
  }) = _AppFeaturesModel;
}

@resource
class AppFeaturesNotifier extends ValueNotifier<AppFeaturesModel> {
  // ignore: avoid_unused_constructor_parameters
  AppFeaturesNotifier(final BuildContext context)
    : super(const AppFeaturesModel());
}

@freezed
abstract class AppNotifierState with _$AppNotifierState {
  const factory AppNotifierState({
    @Default(AppStatus.loading) final AppStatus status,
  }) = _AppNotifierState;
}

class AppNotifierDto {
  AppNotifierDto(final BuildContext context)
    : projectsNotifier = context.read(),
      tagsNotifier = context.read(),
      projectsRepository = context.read(),
      tagsRepository = context.read();
  final ProjectsNotifier projectsNotifier;
  final ProjectsRepository projectsRepository;
  final TagsNotifier tagsNotifier;
  final TagsRepository tagsRepository;
}

class AppNotifier extends ValueNotifier<AppNotifierState> {
  AppNotifier(final BuildContext context)
    : dto = AppNotifierDto(context),
      super(const AppNotifierState());

  final AppNotifierDto dto;

  // TODO(arenukvern): add logic for connection change,
  void updateAppStatus(final AppStatus status) =>
      setValue(value.copyWith(status: status));

  Future<void> restoreFromDbSave({
    required final DbSaveModel dbSave,
    required final BuildContext context,
  }) async {
    final l10n = context.l10n;

    await dto.projectsRepository.putAll(projects: dbSave.projects);
    await dto.tagsRepository.putAll(
      dbSave.tags.toMap(
        toKey: (final item) => item.id,
        toValue: (final item) => item,
      ),
    );
    dto.projectsNotifier.onReset();

    await Future.wait([
      dto.projectsNotifier.onLocalUserLoad(),
      dto.tagsNotifier.onLocalUserLoad(),
    ]);

    LaToast.info(context, l10n.projectsFromFileRestored);
  }
}
