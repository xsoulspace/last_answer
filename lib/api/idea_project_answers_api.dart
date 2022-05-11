part of api;

class IdeaProjectAnswersApi extends AbstractApiProps<IdeaProjectAnswerModel>
    with AbstractApiMixin<IdeaProjectAnswerModel>
    implements AbstractApi<IdeaProjectAnswerModel> {
  IdeaProjectAnswersApi({
    required this.client,
  });
  @override
  final fromJson = IdeaProjectAnswerModel.fromJson;
  @override
  final modelToJson = IdeaProjectAnswerModel.modelToJson;

  @override
  final tableName = 'idea_project_answers';

  @override
  final SupabaseClient client;
}
