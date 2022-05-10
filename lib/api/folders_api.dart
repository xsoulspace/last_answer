part of api;

class FoldersApi implements AbstractApi<ProjectFolder> {
  FoldersApi({
    required this.client,
  });
  @override
  final SupabaseClient client;

  @override
  Iterable<ProjectFolder> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  ProjectFolder getById(final String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  void subscribeToDeletes() {
    // TODO: implement subscribeToDeletes
  }

  @override
  void subscribeToNew() {
    // TODO: implement subscribeToNew
  }

  @override
  void subscribeToUpdates() {
    // TODO: implement subscribeToUpdates
  }
}
