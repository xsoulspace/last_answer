import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/instance_updater.dart';
import 'package:lastanswer/pack_settings/sync/_models/instance_diff.dart';
import 'package:lastanswer/pack_settings/sync/_models/instance_update_policy.dart';
import 'package:lastanswer/pack_settings/sync/_models/model_updater_diff.dart';
import 'package:lastanswer/pack_settings/sync/client_sync_services/client_folder_sync_service.dart';
import 'package:lastanswer/pack_settings/sync/server_sync_services/server_folder_sync_service.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

FolderUpdater createFolderUpdater(
  final BuildContext context,
) =>
    FolderUpdater.of(
      clientSyncService: context.read<ClientFolderSyncService>(),
      foldersNotifier: context.read(),
      serverSyncService: context.read<ServerFolderSyncService>(),
    );

class FolderUpdater extends InstanceUpdater<ProjectFolder, ProjectFolderModel,
    ProjectFoldersNotifier> {
  FolderUpdater.of({
    required super.clientSyncService,
    required this.serverSyncService,
    required this.foldersNotifier,
  });
  final ServerFolderSyncService serverSyncService;
  final ProjectFoldersNotifier foldersNotifier;

  @override
  Future<InstanceUpdaterDto<ProjectFolder, ProjectFolderModel>> compareContent({
    required final InstanceUpdaterDto<ProjectFolder, ProjectFolderModel> dto,
  }) async {
    return compareDiffContent(
      diff: dto,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        ProjectFolderModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        bool originalWasUpdated = updatableDiff.originalWasUpdated;
        final policy = getPolicyForDiff(updatableDiff);
        if (policy == InstanceUpdatePolicy.noUpdateRequired) {
          return updatableDiff;
        }

        /// check title
        if (original.title != other.title) {
          switch (policy) {
            case InstanceUpdatePolicy.useClientVersion:
              other = other.copyWith(title: original.title);
              otherWasUpdated = true;
              break;

            case InstanceUpdatePolicy.useServerVersion:
              original.title = other.title;
              originalWasUpdated = true;
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
    final UpdatableInstanceDiff<ProjectFolder, ProjectFolderModel> diff,
  ) {
    if (diff.original.updatedAt == diff.other.updatedAt) {
      return InstanceUpdatePolicy.noUpdateRequired;
    }
    final useOriginalPolicy =
        diff.original.updatedAt.isAfter(diff.other.updatedAt);
    if (useOriginalPolicy) return InstanceUpdatePolicy.useClientVersion;

    return InstanceUpdatePolicy.useServerVersion;
  }

  @override
  Future<void> saveChanges({
    required final InstanceUpdaterDto<ProjectFolder, ProjectFolderModel> dto,
  }) async {
    await Future.wait([
      super.saveChanges(dto: dto),
      serverSyncService.applyUpdaterDto(dto: dto),
    ]);
  }
}
