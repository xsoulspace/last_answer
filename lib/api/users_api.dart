import 'package:lastanswer/api/abstract_api.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersApi extends AbstractApiProps<UserModel>
    with AbstractApiMixin<UserModel>
    implements AbstractApi<UserModel> {
  UsersApi({
    required this.client,
  });
  @override
  final SupabaseClient client;

  @override
  final fromJson = UserModel.fromJson;

  @override
  final modelToJson = UserModel.modelToJson;

  @override
  final tableName = 'users';
}
