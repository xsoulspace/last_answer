import 'package:core_server_server/src/endpoints/purchases_endpoint.dart';
import 'package:core_server_server/src/extensions/extensions.dart';
import 'package:core_server_server/src/generated/user.dart';
import 'package:serverpod/serverpod.dart';
import 'package:shared_models/shared_models.dart';

typedef ServerUserId = int;
// This is an example endpoint of your server. It's best practice to use the
// `Endpoint` ending of the class name, but it will be removed when accessing
// the endpoint from the client. I.e., this endpoint can be accessed through
// `client.example` on the client side.

// After adding or modifying an endpoint, you will need to run
// `serverpod generate` to update the server and client code.
// You create methods in your endpoint which are accessible from the client by
// creating a public method with `Session` as its first parameter. Supported
// parameter types are `bool`, `int`, `double`, `String`, `DateTime`, and any
// objects that are generated from your `protocol` directory. The methods
// should return a typed future; the same types as for the parameters are
// supported. The `session` object provides access to the database, logging,
// passwords, and information about the request being made to the server.
class UserEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<RemoteUserModel> getUser(final Session session) async {
    final userId = await session.userId;
    final user = await User.findById(session, userId);
    if (user == null) throw Exception('User not found');
    return RemoteUserModel.fromRawJson(user.toJson());
  }

  Future<void> putUser(
    final Session session,
    final RemoteUserModel? user,
  ) async =>
      UserEndpointImpl().putUser(session, user);

  Future<void> deleteUser(final Session session) async {
    final userId = await session.userId;
    final user = await User.findById(session, userId);
    if (user == null) return;
    await User.deleteRow(session, user);
  }
}

class UserEndpointImpl {
  Future<void> putUser(
    final Session session,
    final RemoteUserModel? user,
  ) async {
    final userId = await session.userId;
    final existedUser = await User.findById(session, userId);
    final updatedUser = User(
      id: userId,
      created_at: existedUser?.created_at ?? DateTime.now(),
      updated_at: existedUser?.updated_at ?? DateTime.now(),
    );
    if (existedUser == null) {
      await User.insert(session, updatedUser);
      await PurchasesEndpointImpl().createPurchases(session);
    } else {
      await User.update(session, updatedUser);
    }
  }
}
