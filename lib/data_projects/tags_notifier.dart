import 'package:lastanswer/common_imports.dart';

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
