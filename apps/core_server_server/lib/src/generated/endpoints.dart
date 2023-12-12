/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/auth_endpoint.dart' as _i2;
import '../endpoints/purchase_endpoint.dart' as _i3;
import '../endpoints/purchases_endpoint.dart' as _i4;
import '../endpoints/user_endpoint.dart' as _i5;
import 'package:core_server_server/src/generated/purchase.dart' as _i6;
import 'package:shared_models/src/models/models.dart' as _i7;
import 'package:serverpod_auth_server/module.dart' as _i8;

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
      'user': _i5.UserEndpoint()
        ..initialize(
          server,
          'user',
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
        'setSubscription': _i1.MethodConnector(
          name: 'setSubscription',
          params: {
            'purchaseId': _i1.ParameterDescription(
              name: 'purchaseId',
              type: _i1.getType<_i6.Purchase>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['purchase'] as _i3.PurchaseEndpoint).setSubscription(
            session,
            params['purchaseId'],
          ),
        ),
        'cancelAutorenew': _i1.MethodConnector(
          name: 'cancelAutorenew',
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
              (endpoints['purchase'] as _i3.PurchaseEndpoint).cancelAutorenew(
            session,
            params['purchaseId'],
          ),
        ),
        'resumeAutorenew': _i1.MethodConnector(
          name: 'resumeAutorenew',
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
              (endpoints['purchase'] as _i3.PurchaseEndpoint).resumeAutorenew(
            session,
            params['purchaseId'],
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
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'getUser': _i1.MethodConnector(
          name: 'getUser',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i5.UserEndpoint).getUser(session),
        ),
        'putUser': _i1.MethodConnector(
          name: 'putUser',
          params: {
            'user': _i1.ParameterDescription(
              name: 'user',
              type: _i1.getType<_i7.RemoteUserModel?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i5.UserEndpoint).putUser(
            session,
            params['user'],
          ),
        ),
        'deleteUser': _i1.MethodConnector(
          name: 'deleteUser',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i5.UserEndpoint).deleteUser(session),
        ),
      },
    );
    modules['serverpod_auth'] = _i8.Endpoints()..initializeEndpoints(server);
  }
}
