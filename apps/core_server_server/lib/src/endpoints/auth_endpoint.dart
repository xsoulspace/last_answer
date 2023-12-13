import 'package:core_server_server/src/endpoints/user_endpoint.dart';
import 'package:core_server_server/src/generated/user.dart';
import 'package:serverpod/serverpod.dart';

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
class AuthEndpoint extends Endpoint {
  Future<void> signInVkID(final Session session, final String name) async {
    'Hello $name';
    // Users.createUser(session, userInfo);
  }

  Future<void> completeSignIn(final Session session) async {
    final isSignedIn = await session.isUserSignedIn;
    if (!isSignedIn) throw Exception('User is unauthorized');
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) throw Exception('User is unauthorized');
    final user = await User.findSingleRow(
      session,
      where: (final v) => v.user_id.equals(userId),
    );
    if (user != null) return;
    await UserEndpointImpl().putUser(session, null);
  }
}
