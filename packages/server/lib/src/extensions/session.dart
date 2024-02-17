import 'package:server/src/endpoints/user_endpoint.dart';
import 'package:serverpod/serverpod.dart';

extension SessionExtension on Session {
  Future<ServerUserId> get userId async {
    final id = await auth.authenticatedUserId;
    return id!;
  }
}
