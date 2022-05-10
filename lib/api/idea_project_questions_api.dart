part of api;

class IdeaProjectQuestionApi implements AbstractApi<IdeaProjectQuestion> {
  IdeaProjectQuestionApi({
    required this.client,
  });
  @override
  final SupabaseClient client;
}
