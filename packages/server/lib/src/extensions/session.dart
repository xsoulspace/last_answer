import 'package:server/src/endpoints/user_endpoint.dart';
import 'package:serverpod/serverpod.dart';

extension SessionExtension on Session {
  Future<ServerUserId> get userId async {
    final auth = await authenticated;
    final id = auth?.userId;
    if (id == null) throw Exception('User is unauthorized');
    return id;
  }
}
