import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

final class TagsNotifier
    extends MapStateNotifier<ProjectTagModelId, ProjectTagModel> {
  TagsNotifier(final BuildContext context)
      : super(repository: context.read<TagsRepository>());
  Future<void> onLocalUserLoad() async {
    final tags = repository!.getAll();
    assignAll(tags);
  }
}
