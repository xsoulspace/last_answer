/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/auth_endpoint.dart' as _i2;
import '../endpoints/purchase_endpoint.dart' as _i3;
import '../endpoints/purchases_endpoint.dart' as _i4;
import 'package:core_server_server/src/generated/purchase.dart' as _i5;
import 'package:shared_models/src/models/models.dart' as _i6;
import 'package:serverpod_auth_server/module.dart' as _i7;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'auth': _i2.AuthEndpoint()
        ..initialize(
          server,
          'auth',
          null,
        ),
      'purchase': _i3.PurchaseEndpoint()
        ..initialize(
          server,
          'purchase',
          null,
        ),
      'purchases': _i4.PurchasesEndpoint()
        ..initialize(
          server,
          'purchases',
          null,
        ),
    };
    connectors['auth'] = _i1.EndpointConnector(
      name: 'auth',
      endpoint: endpoints['auth']!,
      methodConnectors: {
        'signInVkID': _i1.MethodConnector(
          name: 'signInVkID',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['auth'] as _i2.AuthEndpoint).signInVkID(
            session,
            params['name'],
          ),
        ),
        'completeSignIn': _i1.MethodConnector(
          name: 'completeSignIn',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['auth'] as _i2.AuthEndpoint).completeSignIn(session),
        ),
      },
    );
    connectors['purchase'] = _i1.EndpointConnector(
      name: 'purchase',
      endpoint: endpoints['purchase']!,
      methodConnectors: {
        'buySubscription': _i1.MethodConnector(
          name: 'buySubscription',
          params: {
            'purchaseId': _i1.ParameterDescription(
              name: 'purchaseId',
              type: _i1.getType<_i5.Purchase>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['purchase'] as _i3.PurchaseEndpoint).buySubscription(
            session,
            params['purchaseId'],
          ),
        ),
        'cancelSubscriptionAutorenew': _i1.MethodConnector(
          name: 'cancelSubscriptionAutorenew',
          params: {
            'purchaseId': _i1.ParameterDescription(
              name: 'purchaseId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['purchase'] as _i3.PurchaseEndpoint)
                  .cancelSubscriptionAutorenew(
            session,
            params['purchaseId'],
          ),
        ),
        'resumeSubscriptionAutorenew': _i1.MethodConnector(
          name: 'resumeSubscriptionAutorenew',
          params: {
            'purchaseId': _i1.ParameterDescription(
              name: 'purchaseId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['purchase'] as _i3.PurchaseEndpoint)
                  .resumeSubscriptionAutorenew(
            session,
            params['purchaseId'],
          ),
        ),
        'verifyNativeMobilePurchase': _i1.MethodConnector(
          name: 'verifyNativeMobilePurchase',
          params: {
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<_i6.IAPId>(),
              nullable: false,
            ),
            'verificationData': _i1.ParameterDescription(
              name: 'verificationData',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'provider': _i1.ParameterDescription(
              name: 'provider',
              type: _i1.getType<_i6.PurchasePaymentProvider>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['purchase'] as _i3.PurchaseEndpoint)
                  .verifyNativeMobilePurchase(
            session,
            params['productId'],
            params['verificationData'],
            params['provider'],
          ),
        ),
      },
    );
    connectors['purchases'] = _i1.EndpointConnector(
      name: 'purchases',
      endpoint: endpoints['purchases']!,
      methodConnectors: {
        'createPurchases': _i1.MethodConnector(
          name: 'createPurchases',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['purchases'] as _i4.PurchasesEndpoint)
                  .createPurchases(session),
        )
      },
    );
    modules['serverpod_auth'] = _i7.Endpoints()..initializeEndpoints(server);
  }
}
