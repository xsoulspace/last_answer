import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/instance_updater.dart';
import 'package:lastanswer/pack_settings/sync/_models/instance_diff.dart';
import 'package:lastanswer/pack_settings/sync/_models/instance_update_policy.dart';
import 'package:lastanswer/pack_settings/sync/_models/model_updater_diff.dart';
import 'package:lastanswer/pack_settings/sync/client_sync_services/client_idea_question_sync_service.dart';
import 'package:lastanswer/pack_settings/sync/server_sync_services/server_idea_question_sync_service.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

IdeaQuestionUpdater createIdeaQuestionUpdater(
  final BuildContext context,
) =>
    IdeaQuestionUpdater.of(
      clientSyncService: context.read<ClientIdeaQuestionSyncService>(),
      foldersNotifier: context.read(),
      serverSyncService: context.read<ServerIdeaQuestionSyncService>(),
    );

class IdeaQuestionUpdater extends InstanceUpdater<IdeaProjectQuestion,
    IdeaProjectQuestionModel, IdeaProjectQuestionsNotifier> {
  IdeaQuestionUpdater.of({
    required final super.clientSyncService,
    required final this.serverSyncService,
    required this.foldersNotifier,
  });
  final ServerIdeaQuestionSyncService serverSyncService;
  final ProjectFoldersNotifier foldersNotifier;

  @override
  Future<InstanceUpdaterDto<IdeaProjectQuestion, IdeaProjectQuestionModel>>
      compareContent({
    required final InstanceUpdaterDto<IdeaProjectQuestion,
            IdeaProjectQuestionModel>
        dto,
  }) async {
    return compareDiffContent(
      diff: dto,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        IdeaProjectQuestionModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        final bool originalWasUpdated = updatableDiff.originalWasUpdated;
        final policy = getPolicyForDiff(updatableDiff);

        /// check title
        if (original.title != other.localizedTitle) {
          switch (policy) {
            case InstanceUpdatePolicy.useServerVersion:
              other =
                  other.copyWith(title: jsonEncode(original.title.toJson()));
              otherWasUpdated = true;
              break;
            case InstanceUpdatePolicy.noUpdateRequired:
              break;
            default:
              // TODO(arenukvern): description
              throw UnimplementedError();
          }
        }

        return UpdatableInstanceDiff(
          original: original,
          other: other,
          originalWasUpdated: originalWasUpdated,
          otherWasUpdated: otherWasUpdated,
        );
      },
    );
  }

  @override
  InstanceUpdatePolicy getPolicyForDiff(
    final UpdatableInstanceDiff<IdeaProjectQuestion, IdeaProjectQuestionModel>
        diff,
  ) {
    return InstanceUpdatePolicy.useServerVersion;
  }

  @override
  Future<void> saveChanges({
    required final InstanceUpdaterDto<IdeaProjectQuestion,
            IdeaProjectQuestionModel>
        dto,
  }) async {
    await Future.wait([
      super.saveChanges(dto: dto),
      serverSyncService.applyUpdaterDto(dto: dto),
    ]);
  }
}
