import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/client_sync_service.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class ClientFolderSyncService extends HiveClientSyncServiceImpl<ProjectFolder,
    ProjectFolderModel, ProjectFoldersNotifier> {
  ClientFolderSyncService({required super.context});
  factory ClientFolderSyncService.of(final BuildContext context) =>
      ClientFolderSyncService(context: context);
  @override
  Future<void> onCreateFromOther(
    final Iterable<ProjectFolderModel> elements,
  ) async {
    final foldersNotifier = context.read<ProjectFoldersNotifier>();
    await Future.wait(
      elements.map((final model) async {
        final folder = await ProjectFolder.fromModel(model);
        foldersNotifier.put(key: folder.id, value: folder);
      }),
    );
  }
}
