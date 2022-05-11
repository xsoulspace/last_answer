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
  final modelToJson = ProjectFolderModel.modelToJson;
  @override
  final tableName = 'folders';

  @override
  final SupabaseClient client;
}
