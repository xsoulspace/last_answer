import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/client_sync_service.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

class ClientIdeaSyncService extends HiveClientSyncServiceImpl<IdeaProject,
    IdeaProjectModel, IdeaProjectsNotifier> {
  ClientIdeaSyncService({required final super.context});
  factory ClientIdeaSyncService.of(final BuildContext context) =>
      ClientIdeaSyncService(context: context);
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectModel> elements,
  ) async {
    final ideasNotifier = context.read<IdeaProjectsNotifier>();
    await Future.wait(
      elements.map((final model) async {
        final idea = await IdeaProject.fromModel(
          model: model,
          context: context,
        );
        ideasNotifier.put(key: idea.id, value: idea);
      }),
    );
  }
}
