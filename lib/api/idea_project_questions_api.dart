import 'package:lastanswer/api/abstract_api.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
