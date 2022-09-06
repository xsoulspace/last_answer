import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/server_sync_service.dart';
import 'package:provider/provider.dart';

ServerIdeaAnswerSyncService createServerIdeaAnswerSyncService(
  final BuildContext context,
) =>
    ServerIdeaAnswerSyncService(
      api: context.read<IdeaProjectAnswersApi>(),
      usersNotifier: context.read(),
    );

class ServerIdeaAnswerSyncService
    extends ServerSyncServiceImpl<IdeaProjectAnswer, IdeaProjectAnswerModel> {
  ServerIdeaAnswerSyncService({
    required super.api,
    required super.usersNotifier,
  });

  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectAnswer> elements,
  ) async {
    final models = elements
        .map((final e) => e.toModel(user: usersNotifier.currentUser.value));
    await onUpdate(models);
  }
}
