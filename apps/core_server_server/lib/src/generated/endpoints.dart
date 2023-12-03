/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/purchase_endpoint.dart' as _i2;
import '../endpoints/user_endpoint.dart' as _i3;
import 'package:core_server_server/src/generated/purchase.dart' as _i4;
import 'package:serverpod_auth_server/module.dart' as _i5;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'purchase': _i2.PurchaseEndpoint()
        ..initialize(
          server,
          'purchase',
          null,
        ),
      'user': _i3.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
    };
    connectors['purchase'] = _i1.EndpointConnector(
      name: 'purchase',
      endpoint: endpoints['purchase']!,
      methodConnectors: {
        'setSubscription': _i1.MethodConnector(
          name: 'setSubscription',
          params: {
            'purchaseId': _i1.ParameterDescription(
              name: 'purchaseId',
              type: _i1.getType<_i4.Purchase>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['purchase'] as _i2.PurchaseEndpoint).setSubscription(
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
              (endpoints['purchase'] as _i2.PurchaseEndpoint).cancelAutorenew(
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
              (endpoints['purchase'] as _i2.PurchaseEndpoint).resumeAutorenew(
            session,
            params['purchaseId'],
          ),
        ),
      },
    );
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'signinVkID': _i1.MethodConnector(
          name: 'signinVkID',
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
              (endpoints['user'] as _i3.UserEndpoint).signinVkID(
            session,
            params['name'],
          ),
        ),
        'signinGoogle': _i1.MethodConnector(
          name: 'signinGoogle',
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
              (endpoints['user'] as _i3.UserEndpoint).signinGoogle(
            session,
            params['name'],
          ),
        ),
        'deleteUser': _i1.MethodConnector(
          name: 'deleteUser',
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
              (endpoints['user'] as _i3.UserEndpoint).deleteUser(
            session,
            params['name'],
          ),
        ),
      },
    );
    modules['serverpod_auth'] = _i5.Endpoints()..initializeEndpoints(server);
  }
}
