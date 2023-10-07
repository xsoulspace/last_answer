import 'package:lastanswer/api/abstract_api.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
