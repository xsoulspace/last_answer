part of pack_settings;

ServerIdeaSyncService createServerIdeaSyncService(
  final BuildContext context,
) =>
    ServerIdeaSyncService(
      api: context.read<ProjectsApi>(),
      usersNotifier: context.read(),
    );

class ServerIdeaSyncService
    extends ServerSyncServiceImpl<IdeaProject, IdeaProjectModel> {
  ServerIdeaSyncService({
    required final super.api,
    required this.usersNotifier,
  });
  final UsersNotifier usersNotifier;
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProject> elements,
  ) async {
    final models = elements.map(
      (final e) => e.toModel(user: usersNotifier.currentUser.value),
    );
    await onUpdate(models);
  }
}
