import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/client_sync_service.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class ClientNoteSyncService extends HiveClientSyncServiceImpl<NoteProject,
    NoteProjectModel, NoteProjectsNotifier> {
  ClientNoteSyncService({required final super.context});

  factory ClientNoteSyncService.of(final BuildContext context) =>
      ClientNoteSyncService(context: context);

  @override
  Future<void> onCreateFromOther(
    final Iterable<NoteProjectModel> elements,
  ) async {
    final notesNotifier = context.read<NoteProjectsNotifier>();
    await Future.wait(
      elements.map((final model) async {
        final idea = await NoteProject.fromModel(
          model: model,
          context: context,
        );
        notesNotifier.put(key: idea.id, value: idea);
      }),
    );
  }
}
