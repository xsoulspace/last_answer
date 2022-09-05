import 'package:lastanswer/api/abstract_api.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
