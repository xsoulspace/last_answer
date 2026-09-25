import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';

final class TagsNotifier
    extends MapStateNotifier<ProjectTagModelId, ProjectTagModel> {
  TagsNotifier(final BuildContext context)
    : tagsRepository = context.read(),
      super(toKey: (final e) => e.id);
  final TagsRepository tagsRepository;
  Future<void> onLocalUserLoad() async {
    final tags = await tagsRepository.getAll();
    assignAll(tags);
  }
}
