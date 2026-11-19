import 'package:lastanswer/data_agents/subscriptions/grok_credentials.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_gateway_contract.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_gateway_stub.dart'
    if (dart.library.io) 'package:lastanswer/data_agents/subscriptions/grok_gateway_io.dart'
    as platform;

export 'grok_gateway_contract.dart';

GrokGateway createGrokGateway(GrokCredentials credentials) =>
    platform.createGrokGateway(credentials);
