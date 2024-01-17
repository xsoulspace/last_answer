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
import 'package:core_server_client/src/protocol/purchase.dart' as _i3;
import 'package:shared_models/src/models/models.dart' as _i4;
import 'package:serverpod_auth_client/module.dart' as _i5;
import 'protocol.dart' as _i6;

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

/// API to make or cancel purchase
/// {@category Endpoint}
class EndpointPurchase extends _i1.EndpointRef {
  EndpointPurchase(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'purchase';

  _i2.Future<bool> buySubscription(_i3.Purchase purchaseId) =>
      caller.callServerEndpoint<bool>(
        'purchase',
        'buySubscription',
        {'purchaseId': purchaseId},
      );

  _i2.Future<bool> cancelSubscriptionAutorenew(int purchaseId) =>
      caller.callServerEndpoint<bool>(
        'purchase',
        'cancelSubscriptionAutorenew',
        {'purchaseId': purchaseId},
      );

  _i2.Future<bool> resumeSubscriptionAutorenew(int purchaseId) =>
      caller.callServerEndpoint<bool>(
        'purchase',
        'resumeSubscriptionAutorenew',
        {'purchaseId': purchaseId},
      );

  _i2.Future<_i4.PurchaseModel?> verifyNativeMobilePurchase(
    _i4.IAPId productId,
    String verificationData,
    _i4.PurchasePaymentProvider provider,
  ) =>
      caller.callServerEndpoint<_i4.PurchaseModel?>(
        'purchase',
        'verifyNativeMobilePurchase',
        {
          'productId': productId,
          'verificationData': verificationData,
          'provider': provider,
        },
      );
}

/// API to get information about purchases
/// {@category Endpoint}
class EndpointPurchases extends _i1.EndpointRef {
  EndpointPurchases(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'purchases';

  _i2.Future<void> createPurchases() => caller.callServerEndpoint<void>(
        'purchases',
        'createPurchases',
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
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
  }) : super(
          host,
          _i6.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
        ) {
    auth = EndpointAuth(this);
    purchase = EndpointPurchase(this);
    purchases = EndpointPurchases(this);
    modules = _Modules(this);
  }

  late final EndpointAuth auth;

  late final EndpointPurchase purchase;

  late final EndpointPurchases purchases;

  late final _Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'auth': auth,
        'purchase': purchase,
        'purchases': purchases,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
