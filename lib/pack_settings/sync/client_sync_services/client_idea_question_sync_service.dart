import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/client_sync_service.dart';
import 'package:lastanswer/state/state.dart';

class ClientIdeaQuestionSyncService extends HiveClientSyncServiceImpl<
    IdeaProjectQuestion,
    IdeaProjectQuestionModel,
    IdeaProjectQuestionsNotifier> {
  ClientIdeaQuestionSyncService({required final super.context});
  factory ClientIdeaQuestionSyncService.of(final BuildContext context) =>
      ClientIdeaQuestionSyncService(context: context);
}
