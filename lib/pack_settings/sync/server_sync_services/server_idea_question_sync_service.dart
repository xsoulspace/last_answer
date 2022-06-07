import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/server_sync_service.dart';
import 'package:provider/provider.dart';

ServerIdeaQuestionSyncService createServerIdeaQuestionSyncService(
  final BuildContext context,
) =>
    ServerIdeaQuestionSyncService(
      api: context.read<IdeaProjectQuestionApi>(),
      usersNotifier: context.read(),
    );

class ServerIdeaQuestionSyncService extends ServerSyncServiceImpl<
    IdeaProjectQuestion, IdeaProjectQuestionModel> {
  ServerIdeaQuestionSyncService({
    required final super.api,
    required final super.usersNotifier,
  });
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectQuestion> elements,
  ) async {
    final models = elements
        .map((final e) => e.toModel(user: usersNotifier.currentUser.value));
    await onUpdate(models);
  }
}
