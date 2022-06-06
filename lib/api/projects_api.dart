part of api;

class ProjectsApi extends AbstractApiProps<BasicProjectModel>
    with AbstractApiMixin<BasicProjectModel>
    implements AbstractApi<BasicProjectModel> {
  ProjectsApi({
    required this.client,
  });
  @override
  final SupabaseClient client;

  @override
  final fromJson = BasicProjectModel.fromJson;
  @override
  final modelToJson = BasicProjectModel.modelToJson;

  @override
  final tableName = 'projects';
}
