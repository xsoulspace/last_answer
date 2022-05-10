part of api;

class IdeaProjectAnswersApi implements AbstractApi<IdeaProjectAnswer> {
  IdeaProjectAnswersApi({
    required this.client,
  });
  @override
  final SupabaseClient client;
}
