import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/chatgpt_gateway_io.dart'
    as platform;

export 'chatgpt_gateway_contract.dart';

ChatGptGateway createChatGptGateway(ChatGptCredentials credentials) =>
    platform.createChatGptGateway(credentials);
