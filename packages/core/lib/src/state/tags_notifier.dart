import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../core.dart';

final class TagsNotifier
    extends MapStateNotifier<ProjectTagModelId, ProjectTagModel> {
  TagsNotifier(final BuildContext context)
      : super(repository: context.read<TagsRepository>());
  Future<void> onLocalUserLoad() async {
    final tags = repository!.getAll();
    assignAll(tags);
  }

  Future<void> createTag(final BuildContext context) async {
    // TODO(arenukvern): description,
    showAdaptiveDialog(
      context: context,
      barrierDismissible: true,
      builder: (final context) => AlertDialog.adaptive(
        title: const Text('Create folder'),
        content: const Card(
          child: UiTextField(),
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () {}, child: const Text('Save')),
        ],
      ),
    );
  }
}
