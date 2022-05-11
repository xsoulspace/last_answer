part of api;

class FoldersApi extends AbstractApiProps<ProjectFolderModel>
    with AbstractApiMixin<ProjectFolderModel>
    implements AbstractApi<ProjectFolderModel> {
  FoldersApi({
    required this.client,
  });
  @override
  final fromJson = ProjectFolderModel.fromJson;

  @override
  final tableName = 'folders';

  @override
  final SupabaseClient client;

  @override
  Future<Iterable<ProjectFolderModel>> getAll() async {
    final response = await _getBuilder().select().execute();
    final data = response.data;

    if (response.hasError) throw Exception(data);

    return List.castFrom<dynamic, Map<String, dynamic>>(data).map(
      ProjectFolderModel.fromJson,
    );
  }

  @override
  Future<ProjectFolderModel?> getById(final String id) async {
    final response = await _getBuilder().select().eq('id', id).execute();
    final data = response.data;
    if (response.hasError) throw Exception(data);

    return List.castFrom<dynamic, Map<String, dynamic>>(data)
        .map(
          ProjectFolderModel.fromJson,
        )
        .firstOrNull;
  }
}
