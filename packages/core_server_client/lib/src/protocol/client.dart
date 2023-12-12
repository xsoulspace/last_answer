/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:core_server_client/src/protocol/purchase.dart' as _i3;
import 'package:shared_models/src/models/models.dart' as _i4;
import 'package:serverpod_auth_client/module.dart' as _i5;
import 'dart:io' as _i6;
import 'protocol.dart' as _i7;

class _EndpointAuth extends _i1.EndpointRef {
  _EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  _i2.Future<String> signInVkID(String name) =>
      caller.callServerEndpoint<String>(
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

class _EndpointPurchase extends _i1.EndpointRef {
  _EndpointPurchase(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'purchase';

  _i2.Future<bool> setSubscription(_i3.Purchase purchaseId) =>
      caller.callServerEndpoint<bool>(
        'purchase',
        'setSubscription',
        {'purchaseId': purchaseId},
      );

  _i2.Future<bool> cancelAutorenew(int purchaseId) =>
      caller.callServerEndpoint<bool>(
        'purchase',
        'cancelAutorenew',
        {'purchaseId': purchaseId},
      );

  _i2.Future<bool> resumeAutorenew(int purchaseId) =>
      caller.callServerEndpoint<bool>(
        'purchase',
        'resumeAutorenew',
        {'purchaseId': purchaseId},
      );
}

class _EndpointPurchases extends _i1.EndpointRef {
  _EndpointPurchases(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'purchases';

  _i2.Future<void> createPurchases() => caller.callServerEndpoint<void>(
        'purchases',
        'createPurchases',
        {},
      );
}

class _EndpointUser extends _i1.EndpointRef {
  _EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  _i2.Future<_i4.RemoteUserModel> getUser() =>
      caller.callServerEndpoint<_i4.RemoteUserModel>(
        'user',
        'getUser',
        {},
      );

  _i2.Future<void> putUser(_i4.RemoteUserModel? user) =>
      caller.callServerEndpoint<void>(
        'user',
        'putUser',
        {'user': user},
      );

  _i2.Future<void> deleteUser() => caller.callServerEndpoint<void>(
        'user',
        'deleteUser',
        {},
      );
}

class _Modules {
  _Modules(Client client) {
    auth = _i5.Caller(client);
  }

  late final _i5.Caller auth;
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    _i6.SecurityContext? context,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
  }) : super(
          host,
          _i7.Protocol(),
          context: context,
          authenticationKeyManager: authenticationKeyManager,
        ) {
    auth = _EndpointAuth(this);
    purchase = _EndpointPurchase(this);
    purchases = _EndpointPurchases(this);
    user = _EndpointUser(this);
    modules = _Modules(this);
  }

  late final _EndpointAuth auth;

  late final _EndpointPurchase purchase;

  late final _EndpointPurchases purchases;

  late final _EndpointUser user;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'auth': auth,
        'purchase': purchase,
        'purchases': purchases,
        'user': user,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
