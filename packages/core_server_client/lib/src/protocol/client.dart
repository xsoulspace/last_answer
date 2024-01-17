/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:shared_models/src/models/models.dart' as _i3;
import 'package:serverpod_auth_client/module.dart' as _i4;
import 'protocol.dart' as _i5;

/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  _i2.Future<void> signInVkID(String name) => caller.callServerEndpoint<void>(
        'auth',
        'signInVkID',
        {'name': name},
      );

  _i2.Future<void> completeSignIn() => caller.callServerEndpoint<void>(
        'auth',
        'completeSignIn',
        {},
      );
}

/// {@category Endpoint}
class EndpointUser extends _i1.EndpointRef {
  EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  _i2.Future<_i3.RemoteUserModel> getUser() =>
      caller.callServerEndpoint<_i3.RemoteUserModel>(
        'user',
        'getUser',
        {},
      );

  _i2.Future<void> putUser(_i3.RemoteUserModel? user) =>
      caller.callServerEndpoint<void>(
        'user',
        'putUser',
        {'user': user},
      );

  _i2.Future<bool> receiveAdVideoReward(int daysCount) =>
      caller.callServerEndpoint<bool>(
        'user',
        'receiveAdVideoReward',
        {'daysCount': daysCount},
      );

  _i2.Future<void> deleteUser() => caller.callServerEndpoint<void>(
        'user',
        'deleteUser',
        {},
      );
}

/// API to get information about purchases
/// {@category Endpoint}
class EndpointUserPurchaseInfo extends _i1.EndpointRef {
  EndpointUserPurchaseInfo(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'userPurchaseInfo';

  _i2.Future<void> create() => caller.callServerEndpoint<void>(
        'userPurchaseInfo',
        'create',
        {},
      );
}

class _Modules {
  _Modules(Client client) {
    auth = _i4.Caller(client);
  }

  late final _i4.Caller auth;
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
  }) : super(
          host,
          _i5.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
        ) {
    auth = EndpointAuth(this);
    user = EndpointUser(this);
    userPurchaseInfo = EndpointUserPurchaseInfo(this);
    modules = _Modules(this);
  }

  late final EndpointAuth auth;

  late final EndpointUser user;

  late final EndpointUserPurchaseInfo userPurchaseInfo;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'auth': auth,
        'user': user,
        'userPurchaseInfo': userPurchaseInfo,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
