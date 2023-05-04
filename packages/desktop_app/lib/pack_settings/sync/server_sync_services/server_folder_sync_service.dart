import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/server_sync_service.dart';
import 'package:provider/provider.dart';

ServerFolderSyncService createServerFolderSyncService(
  final BuildContext context,
) =>
    ServerFolderSyncService(
      api: context.read<FoldersApi>(),
      usersNotifier: context.read(),
    );

class ServerFolderSyncService
    extends ServerSyncServiceImpl<ProjectFolder, ProjectFolderModel> {
  ServerFolderSyncService({
    required super.api,
    required super.usersNotifier,
  });
  @override
  Future<void> onCreateFromOther(
    final Iterable<ProjectFolder> elements,
  ) async {
    final models = elements
        .map((final e) => e.toModel(user: usersNotifier.currentUser.value));
    await onUpdate(models);
  }
}
