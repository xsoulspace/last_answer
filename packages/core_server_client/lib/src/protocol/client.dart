/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:core_server_client/src/protocol/purchase.dart' as _i3;
import 'package:serverpod_auth_client/module.dart' as _i4;
import 'dart:io' as _i5;
import 'protocol.dart' as _i6;

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

class _EndpointUser extends _i1.EndpointRef {
  _EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  _i2.Future<String> signinVkID(String name) =>
      caller.callServerEndpoint<String>(
        'user',
        'signinVkID',
        {'name': name},
      );

  _i2.Future<String> signinGoogle(String name) =>
      caller.callServerEndpoint<String>(
        'user',
        'signinGoogle',
        {'name': name},
      );

  _i2.Future<String> deleteUser(String name) =>
      caller.callServerEndpoint<String>(
        'user',
        'deleteUser',
        {'name': name},
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
    _i5.SecurityContext? context,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
  }) : super(
          host,
          _i6.Protocol(),
          context: context,
          authenticationKeyManager: authenticationKeyManager,
        ) {
    purchase = _EndpointPurchase(this);
    user = _EndpointUser(this);
    modules = _Modules(this);
  }

  late final _EndpointPurchase purchase;

  late final _EndpointUser user;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'purchase': purchase,
        'user': user,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
