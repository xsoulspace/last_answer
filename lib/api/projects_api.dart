part of api;

class ProjectsApi implements AbstractApi<BasicProject> {
  ProjectsApi({
    required this.client,
  });
  @override
  final SupabaseClient client;
}
