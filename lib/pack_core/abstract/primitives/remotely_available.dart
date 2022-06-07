import 'package:lastanswer/pack_core/abstract/primitives/has_id.dart';
import 'package:lastanswer/pack_core/abstract/server_models/user_model.dart';

abstract class RemotelyAvailable<T extends HasId> {
  RemotelyAvailable._();
  T toModel({required final UserModel user});
}
