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
import '../endpoints/user_endpoint.dart' as _i3;
import '../endpoints/user_purchase_info_endpoint.dart' as _i4;
import 'package:shared_models/src/models/models.dart' as _i5;
import 'package:serverpod_auth_server/module.dart' as _i6;

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
      'user': _i3.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
      'userPurchaseInfo': _i4.UserPurchaseInfoEndpoint()
        ..initialize(
          server,
          'userPurchaseInfo',
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
              (endpoints['user'] as _i3.UserEndpoint).getUser(session),
        ),
        'putUser': _i1.MethodConnector(
          name: 'putUser',
          params: {
            'user': _i1.ParameterDescription(
              name: 'user',
              type: _i1.getType<_i5.RemoteUserModel?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i3.UserEndpoint).putUser(
            session,
            params['user'],
          ),
        ),
        'receiveAdVideoReward': _i1.MethodConnector(
          name: 'receiveAdVideoReward',
          params: {
            'videoLength': _i1.ParameterDescription(
              name: 'videoLength',
              type: _i1.getType<_i5.AdVideoLengthType>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i3.UserEndpoint).receiveAdVideoReward(
            session,
            params['videoLength'],
          ),
        ),
        'deleteUser': _i1.MethodConnector(
          name: 'deleteUser',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i3.UserEndpoint).deleteUser(session),
        ),
      },
    );
    connectors['userPurchaseInfo'] = _i1.EndpointConnector(
      name: 'userPurchaseInfo',
      endpoint: endpoints['userPurchaseInfo']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['userPurchaseInfo'] as _i4.UserPurchaseInfoEndpoint)
                  .create(session),
        )
      },
    );
    modules['serverpod_auth'] = _i6.Endpoints()..initializeEndpoints(server);
  }
}