import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/client_sync_service.dart';
import 'package:lastanswer/state/state.dart';

class ClientIdeaAnswerSyncService extends HiveClientSyncServiceImpl<
    IdeaProjectAnswer, IdeaProjectAnswerModel, IdeaProjectAnswersNotifier> {
  ClientIdeaAnswerSyncService({required super.context});
  factory ClientIdeaAnswerSyncService.of(final BuildContext context) =>
      ClientIdeaAnswerSyncService(context: context);
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectAnswerModel> elements,
  ) async {}
}
