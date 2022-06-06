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

typedef ApiConstructorCallback<TModel> = TModel Function({
  required SupabaseClient client,
});

typedef ApiProviderCallback<TModel> = TModel Function(BuildContext context);

ApiProviderCallback<TModel> createApiProviderBuilder<TModel>(
  final ApiConstructorCallback<TModel> apiConstructor,
) =>
    (final context) {
      final client = context.read<SupabaseClient>();

      return apiConstructor(client: client);
    };
