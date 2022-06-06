part of api;

class IdeaProjectQuestionApi extends AbstractApiProps<IdeaProjectQuestionModel>
    with AbstractApiMixin<IdeaProjectQuestionModel>
    implements AbstractApi<IdeaProjectQuestionModel> {
  IdeaProjectQuestionApi({
    required this.client,
  });
  @override
  final SupabaseClient client;

  @override
  final fromJson = IdeaProjectQuestionModel.fromJson;
  @override
  final modelToJson = IdeaProjectQuestionModel.modelToJson;

  @override
  final tableName = 'idea_project_questions';
}
