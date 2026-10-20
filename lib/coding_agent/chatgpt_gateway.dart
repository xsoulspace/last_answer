import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/chatgpt_gateway_io.dart'
    as platform;
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

export 'chatgpt_gateway_contract.dart';

ChatGptGateway createChatGptGateway(
  ChatGptCredentials credentials, {
  ContextTransportDiagnosticCapture? Function()? diagnosticCaptureForClient,
}) => platform.createChatGptGateway(
  credentials,
  diagnosticCaptureForClient: diagnosticCaptureForClient,
);
