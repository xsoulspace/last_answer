import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/instance_subscriber.dart';
import 'package:lastanswer/pack_settings/sync/updaters/folder_updater.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

ServerFolderSubscriber createFolderSubscriberNotifier(
  final BuildContext context,
) =>
    ServerFolderSubscriber(
      api: context.read<FoldersApi>(),
      updater: context.read<FolderUpdater>(),
    );

class ServerFolderSubscriber extends SingleInstanceSubscriber<ProjectFolder,
    ProjectFolderModel, ProjectFoldersNotifier> {
  ServerFolderSubscriber({
    required final super.updater,
    required final super.api,
  });
}
