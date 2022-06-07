import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/server_sync_service.dart';
import 'package:lastanswer/pack_settings/sync/_models/model_updater_diff.dart';
import 'package:provider/provider.dart';

ServerProjectsSyncService createServerProjectsSyncService(
  final BuildContext context,
) =>
    ServerProjectsSyncService(
      api: context.read<ProjectsApi>(),
      usersNotifier: context.read(),
    );

class ServerProjectsSyncService
    extends ServerInstancesSyncServiceI<BasicProject, BasicProjectModel> {
  ServerProjectsSyncService({
    required final super.api,
    required final super.usersNotifier,
  });

  @override
  Future<void> onCreateFromOther(
    final Iterable<BasicProject> elements,
  ) async {
    final models = elements.map(
      (final e) => e.toModel(user: usersNotifier.currentUser.value),
    );
    await onUpdate(models);
  }

  @override
  Future<void> onUpdate(
    final Iterable<BasicProjectModel> elements,
  ) async {
    await api.upsertElements(elements);
  }

  @override
  Future<void> onDelete(
    final Iterable<BasicProjectModel> elements,
  ) async {
    for (final el in elements) {
      await api.delete(el);
    }
  }

  @override
  Future<void> applyUpdaterDto({
    required final InstanceUpdaterDto<BasicProject, BasicProjectModel> dto,
  }) async {
    await onCreateFromOther(dto.otherUpdates.toCreateFromOther);
    await onUpdate(dto.otherUpdates.toUpdate);
    await onDelete(dto.otherUpdates.toDelete);
  }
}
