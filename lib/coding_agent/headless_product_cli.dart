import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dart_acp_toolkit/dart_acp_toolkit.dart' show AcpRemoteError;
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway.dart';
import 'package:lastanswer/coding_agent/chatgpt_harness_binding.dart';
import 'package:lastanswer/coding_agent/completion_triggered_cutoff.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/product_autonomy.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openai/chatgpt_auth.dart';
import 'package:xsoulspace_inference_openai/xsoulspace_inference_openai.dart'
    show OpenAiSessionOptions, ResponsesInput;

/// JSON-lines projection of the real product host, not an inference runner.
/// Tasks and candidate actions run asynchronously so consent/cancel remain
/// available. Exactly one operation may own a session at a time.
final class HeadlessProductCli {
  final _credentials = ChatGptCredentials();
  late final _gateway = createChatGptGateway(
    _credentials,
    diagnosticCaptureForClient: () => _projectionId == null
        ? null
        : ContextTransportDiagnosticCapture(observer: _projectionDiagnostic),
  );
  Object? _projectionId;
  bool _projectionCancelled = false;
  int _projectionCalls = 0;
  CancellableInferenceClient? _projectionClient;
  ContextTransportDiagnosticEvent? _projectionUsage;
  final _permissions = <String, PendingPermission>{};
  HarnessHost? _host;
  ProductWorkspaceToolBinding? _tooling;
  ProductWorkspaceTooling? _toolingOwner;
  String _verificationProfile = 'existing';
  String _actorContextOrder = 'legacy';
  StreamSubscription<PendingPermission>? _permissionSubscription;
  Future<void>? _active;
  CompletionTriggeredCutoff? _cutoff;
  Future<void>? _conversation;
  String? _session;
  String? _workspace;
  String? _model;
  int _permissionSequence = 0;
  bool _closing = false;
  Future<void>? _shutdownOperation;

  void _emit(Map<String, Object?> value) => stdout.writeln(jsonEncode(value));

  Future<void> run() async {
    _emit({
      'event': 'ready',
      'protocol': 'last-answer-cli/1',
      'reasoningEffort': 'low',
      'verificationProfiles': ['existing', 'package_snapshot'],
      'commands': [
        'projection_infer',
        'open',
        'task',
        'conversation',
        'autonomy',
        'candidate',
        'permission',
        'status',
        'cancel',
        'shutdown',
      ],
    });
    try {
      await for (final line
          in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        Object? id;
        try {
          final decoded = jsonDecode(line);
          if (decoded is! Map<String, dynamic>) throw const FormatException();
          id = decoded['id'];
          if (id is! String && id is! int) {
            throw const FormatException('request_id_required');
          }
          await _command(id!, decoded);
        } on Object catch (error) {
          _emit({
            'id': id,
            'ok': false,
            // Never serialize arbitrary exception contents from protected auth.
            'error': _errorCode(error),
            'errorType': error.runtimeType.toString(),
            if (error is AcpRemoteError) 'protocolErrorCode': error.code,
          });
        }
        if (_closing) break;
      }
    } finally {
      await _shutdown();
    }
  }

  void _openProgress(Object id, String phase, String status, int elapsedMs) {
    _emit({
      'event': 'openPhase',
      'id': id,
      'phase': phase,
      'status': status,
      'elapsedMs': elapsedMs,
    });
  }

  Future<T> _openPhase<T>(
    Object id,
    String phase,
    Future<T> Function() action,
  ) async {
    final watch = Stopwatch()..start();
    _openProgress(id, phase, 'start', 0);
    final result = await action();
    _openProgress(id, phase, 'completed', watch.elapsedMilliseconds);
    return result;
  }

  String _required(Map<String, dynamic> command, String key) {
    final value = command[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('${key}_required');
    }
    return value;
  }

  Future<void> _command(Object id, Map<String, dynamic> command) async {
    switch (_required(command, 'op')) {
      case 'projection_infer':
        if (_host != null) {
          throw const FormatException('projection_requires_unopened_session');
        }
        final request = buildProjectionDiagnosticRequest(command);
        if (_conversation != null) throw const FormatException('session_busy');
        if (_projectionCalls >= 5) {
          throw const FormatException('projection_inference_cap_reached');
        }
        _launch(id, () => _inferProjection(id, request), requireSession: false);
      case 'open':
        if (_active != null) throw const FormatException('session_busy');
        if (_host != null) throw const FormatException('session_already_open');
        if (command['cloudConsent'] != true) {
          throw const FormatException('explicit_cloud_consent_required');
        }
        final orderName = command['actorContextOrder'] ?? 'legacy';
        final order = switch (orderName) {
          'legacy' => ActorContextOrder.legacy,
          'coder_stable_prefix_v1' => ActorContextOrder.coderStablePrefixV1,
          _ => throw const FormatException('unknown_actor_context_order'),
        };
        final workspace = _required(command, 'workspace');
        final model = _required(command, 'model');
        final verificationProfile =
            command['verificationProfile'] ?? 'existing';
        if (!const {
          'existing',
          'package_snapshot',
        }.contains(verificationProfile)) {
          throw const FormatException('unknown_verification_profile');
        }
        if (verificationProfile == 'package_snapshot' &&
            command['autonomousProduct'] == true) {
          throw const FormatException(
            'package_snapshot_incompatible_with_autonomous_web',
          );
        }
        if (command['reasoningEffort'] != 'low') {
          throw const FormatException('explicit_low_reasoning_required');
        }
        final check = command['checkCommand'];
        if (check == null && command['autonomousProduct'] != true ||
            check != null &&
                (check is! List ||
                    check.isEmpty ||
                    check.any((arg) => arg is! String || arg.isEmpty))) {
          throw const FormatException('explicit_check_command_argv_required');
        }
        final checkCommand = (check as List?)?.cast<String>();
        if (!Directory(workspace).isAbsolute) {
          throw const FormatException('absolute_workspace_required');
        }
        final canonical = await Directory(workspace).resolveSymbolicLinks();
        if (verificationProfile == 'package_snapshot' &&
            (!File('$canonical/.dart_tool/package_config.json').existsSync() ||
                !File('$canonical/lib/main.dart').existsSync())) {
          throw const FormatException('package_snapshot_workspace_required');
        }
        final client = await _openPhase(
          id,
          'account_selection',
          _credentials.activeClientId,
        );
        final profiles = await _openPhase(
          id,
          'account_status',
          _credentials.profiles,
        );
        if (client == null ||
            !profiles.any(
              (profile) =>
                  profile.clientId == client &&
                  profile.signedIn &&
                  profile.planEnabled,
            )) {
          throw const FormatException('subscription_sign_in_required');
        }
        final models = await _openPhase(
          id,
          'model_catalog',
          () => _gateway.models(client),
        );
        if (!models.any((entry) => entry.slug == model)) {
          throw const FormatException('model_not_in_account_catalog');
        }
        final binding = chatGptHarnessBinding(
          gateway: _gateway,
          clientId: client,
          model: model,
        );
        HarnessHost? host;
        try {
          final workspaceToolsWatch = Stopwatch()..start();
          _openProgress(id, 'workspace_tools', 'start', 0);
          final autonomy = command['autonomousProduct'] == true
              ? await ProductAutonomy.start(Directory(canonical))
              : null;
          final owner =
              autonomy?.tooling ??
              ProductWorkspaceTooling.forProfile(verificationProfile as String);
          _toolingOwner = owner;
          final tooling = await owner.prepare(
            canonical,
            ownerKey: this,
            canReviewSaved: (context) =>
                host?.admitsSavedCodeReview(context) ?? false,
          );
          _openProgress(
            id,
            'workspace_tools',
            'completed',
            workspaceToolsWatch.elapsedMilliseconds,
          );
          host = HarnessHost(
            config: HarnessHostConfig(
              backend: chatGptBackend,
              actorContextOrder: order,
              model: model,
              checkCommand: checkCommand ?? await autonomy!.goalCheckCommand(),
              meaningProfile: true,
              inferenceBinding: binding,
              causalTrace: CausalTraceSink(
                (record) {
                  _cutoff?.observe(record);
                  _emit({'event': 'causalTrace', 'record': record.toJson()});
                },
                captureContextDiagnostics:
                    command['captureContextDiagnostics'] == true,
              ),
              extraToolsWithContext: tooling.tools,
              actorToolNames: autonomy == null
                  ? null
                  : {const ToolName('conventional_change')},
            ),
          );
          _permissionSubscription = host.permissionRequests.listen((pending) {
            final permissionId = 'permission-${++_permissionSequence}';
            _permissions[permissionId] = pending;
            _emit({
              'event': 'permission',
              'permissionId': permissionId,
              'request': pending.request.toParams(),
            });
            unawaited(
              pending.future.then((outcome) {
                _permissions.remove(permissionId);
                _emit({
                  'event': 'permissionSettled',
                  'permissionId': permissionId,
                  'outcome': outcome.name,
                });
              }),
            );
          });
          await _openPhase(id, 'host_start', host.start);
          _session = await _openPhase(
            id,
            'session_create',
            () => host!.newSession(canonical),
          );
          _host = host;
          _tooling = tooling;
          _workspace = canonical;
          _model = model;
          _verificationProfile = verificationProfile as String;
          _actorContextOrder = orderName as String;
        } on Object {
          await host?.stop();
          await binding.dispose();
          await _permissionSubscription?.cancel();
          _permissionSubscription = null;
          _toolingOwner?.forgetOwner(this);
          _toolingOwner = null;
          rethrow;
        }
        _emit({'id': id, 'ok': true, ..._status()});
      case 'task':
        final text = _required(command, 'text');
        final maximum = command['maxCompletedInferences'];
        if (maximum != null && (maximum is! int || maximum < 1)) {
          throw const FormatException(
            'positive_max_completed_inferences_required',
          );
        }
        if (maximum != null && _conversation != null) {
          throw const FormatException(
            'cutoff_requires_exclusive_session_operation',
          );
        }
        _launch(id, () async {
          if (maximum is int) {
            _cutoff = CompletionTriggeredCutoff(
              maximum: maximum,
              cancel: () {
                _cancel();
                _emit({
                  'event': 'completionCutoff',
                  'id': id,
                  ..._cutoff!.toJson(),
                });
              },
            );
          }
          final watch = Stopwatch()..start();
          final stop = await _host!.delegateTask(
            _session!,
            text,
            onText: (delta) =>
                _emit({'event': 'text', 'id': id, 'delta': delta}),
            onToolCall: (title) =>
                _emit({'event': 'tool', 'id': id, 'title': title}),
            onHostUpdate: (update) => _emit({
              'event': 'hostUpdate',
              'id': id,
              'update': update.toJson(),
            }),
          );
          return {
            'stopReason': stop.name,
            'elapsedMs': watch.elapsedMilliseconds,
            if (_cutoff != null) 'completionCutoff': _cutoff!.toJson(),
          };
        });
      case 'candidate':
        final action = _required(command, 'action');
        final arguments = command['arguments'];
        if (arguments != null && arguments is! Map<String, dynamic>) {
          throw const FormatException('arguments_must_be_object');
        }
        _launch(
          id,
          () => _host!.conventionalAction(
            _session!,
            action,
            Map<String, Object?>.from(arguments as Map? ?? const {}),
          ),
        );
      case 'conversation':
        if (_cutoff != null) {
          throw const FormatException(
            'conversation_blocked_by_session_operation_cutoff',
          );
        }
        if (_host == null || _session == null) {
          throw const FormatException('open_required');
        }
        if (_conversation != null) {
          throw const FormatException('conversation_busy');
        }
        final text = _required(command, 'text');
        final settled = Completer<void>();
        _conversation = settled.future;
        _emit({'id': id, 'ok': true, 'started': true});
        unawaited(() async {
          try {
            final result = await _host!.converse(_session!, text);
            _emit({
              'event': 'completed',
              'id': id,
              'result': {
                'ok': result.ok,
                'text': result.text,
                'message': result.message,
                'turn': result.turn,
                'timedOut': result.timedOut,
              },
            });
          } on Object catch (error) {
            _emit({
              'event': 'failed',
              'id': id,
              'error': _errorCode(error),
              if (error is AcpRemoteError) 'protocolErrorCode': error.code,
            });
          } finally {
            _conversation = null;
            settled.complete();
          }
        }());
      case 'permission':
        final permissionId = _required(command, 'permissionId');
        final pending = _permissions[permissionId];
        if (pending == null || pending.isAnswered) {
          throw const FormatException('permission_not_pending');
        }
        if (command['allow'] is! bool) {
          throw const FormatException('explicit_permission_answer_required');
        }
        final answered = command['allow'] == true
            ? pending.allow()
            : pending.reject();
        if (!answered) throw const FormatException('permission_not_pending');
        _emit({'id': id, 'ok': true});
      case 'status':
        _emit({'id': id, 'ok': true, ..._status()});
      case 'autonomy':
        final autonomy = _workspace == null
            ? null
            : ProductAutonomy.forWorkspace(_workspace!);
        if (autonomy == null) {
          throw const FormatException('autonomous_product_not_open');
        }
        if (command['action'] == 'revoke') autonomy.revoke();
        _emit({'id': id, 'ok': true, ...autonomy.toJson()});
      case 'cancel':
        _cancel();
        _emit({'id': id, 'ok': true});
      case 'shutdown':
        _closing = true;
        await _shutdown();
        _emit({'id': id, 'ok': true, 'stopped': true});
      default:
        throw const FormatException('unknown_command');
    }
  }

  void _launch(
    Object id,
    Future<Map<String, Object?>> Function() operation, {
    bool requireSession = true,
  }) {
    if (requireSession && (_host == null || _session == null)) {
      throw const FormatException('open_required');
    }
    if (_active != null) throw const FormatException('session_busy');
    _emit({'id': id, 'ok': true, 'started': true});
    // Set the barrier before starting even when an operation fails immediately.
    final settled = Completer<void>();
    _active = settled.future;
    unawaited(() async {
      try {
        final result = await operation();
        _emit({
          'event': 'completed',
          'id': id,
          'result': result,
          ..._diagnostics(),
        });
      } on Object catch (error) {
        _emit({
          'event': 'failed',
          'id': id,
          'error': _errorCode(error),
          'errorType': error.runtimeType.toString(),
          if (error is AcpRemoteError) 'protocolErrorCode': error.code,
          ..._diagnostics(),
        });
      } finally {
        _cutoff = null;
        _active = null;
        settled.complete();
      }
    }());
  }

  Map<String, Object?> _diagnostics() => {
    if (_gateway case final ChatGptTransportDiagnostics diagnostics)
      'transportDecisions': diagnostics.transportDecisions,
  };

  Map<String, Object?> _status() => {
    'running': _host?.isRunning ?? false,
    'sessionId': _session,
    'workspace': _workspace,
    'model': _model,
    'verificationProfile': _verificationProfile,
    'actorContextOrder': _actorContextOrder,
    'reasoningEffort': 'low',
    if (_workspace != null)
      'autonomy': ProductAutonomy.forWorkspace(_workspace!)?.toJson(),
    'busy': _active != null,
    'projectionInferenceCalls': _projectionCalls,
    'projectionInferenceCap': 5,
    if (_cutoff != null) 'completionCutoff': _cutoff!.toJson(),
    'permissions': _permissions.keys.toList(),
    if (_tooling != null) 'coding': _tooling!.toJson(),
    ..._diagnostics(),
  };

  void _projectionDiagnostic(ContextTransportDiagnosticEvent event) {
    if (_projectionId == null) return;
    if (event.stage == ContextTransportDiagnosticStage.settled) {
      _projectionUsage = event;
    }
    _emit({
      'event': 'projectionDiagnostic',
      'id': _projectionId,
      'diagnostic': event.toJson(),
    });
  }

  Future<Map<String, Object?>> _inferProjection(
    Object id,
    InferenceRequest request,
  ) async {
    _projectionId = id;
    _projectionCancelled = false;
    _projectionUsage = null;
    InferenceClient? client;
    void checkCancelled() {
      if (_projectionCancelled) {
        throw const FormatException('projection_cancelled');
      }
    }

    try {
      final account = await _credentials.activeClientId();
      checkCancelled();
      final profiles = await _credentials.profiles();
      checkCancelled();
      if (account == null ||
          !profiles.any(
            (profile) =>
                profile.clientId == account &&
                profile.signedIn &&
                profile.planEnabled,
          )) {
        throw const FormatException('subscription_sign_in_required');
      }
      client = _gateway.inferenceClient(account, 'gpt-6-luna');
      if (client is! CancellableInferenceClient ||
          client is! ReasoningEffortInferenceClient ||
          !(client as ReasoningEffortInferenceClient).supportedReasoningEfforts
              .contains('low')) {
        throw const FormatException('projection_transport_capability_required');
      }
      _projectionClient = client;
      checkCancelled();
      if (_projectionCalls >= 5) {
        throw const FormatException('projection_inference_cap_reached');
      }
      // Count invocation before dispatch, including unknown/cancelled outcomes.
      _projectionCalls++;
      final result = await client.infer(request);
      final output = result.data?.rawOutput;
      final usage = _projectionUsage;
      return {
        'ok': result.success,
        'cancelled': _projectionCancelled,
        'replyExactlyOk': output == 'OK',
        'outputBytes': output == null ? null : utf8.encode(output).length,
        'outputSha256': output == null
            ? null
            : sha256.convert(utf8.encode(output)).toString(),
        'usageReported': usage?.usageReported ?? false,
        'numericUsage': usage?.usageReported == true
            ? usage!.numericUsage
            : null,
        'inferenceCalls': _projectionCalls,
        'inferenceCap': 5,
      };
    } finally {
      try {
        if (client != null) await _gateway.releaseClient(client);
      } finally {
        _projectionClient = null;
        _projectionId = null;
      }
    }
  }

  void _cancel() {
    if (_projectionId != null) {
      _projectionCancelled = true;
      _projectionClient?.cancelActive();
    }
    for (final pending in _permissions.values.toList()) {
      pending.reject();
    }
    if (_session case final session?) _host?.cancel(session);
  }

  String _errorCode(Object error) => switch (error) {
    ChatGptAuthException(:final code) => code,
    FormatException(:final message) => message,
    _ => 'command_failed',
  };

  Future<void> _shutdown() => _shutdownOperation ??= _stop();

  Future<void> _stop() async {
    _cancel();
    await _active;
    await _conversation;
    final host = _host;
    _host = null;
    try {
      await host?.stop();
      await host?.config.inferenceBinding?.dispose();
    } finally {
      await _permissionSubscription?.cancel();
      _toolingOwner?.forgetOwner(this);
      _toolingOwner = null;
      if (_workspace != null) {
        final autonomy = ProductAutonomy.forWorkspace(_workspace!);
        autonomy?.revoke();
        await autonomy?.preview.close();
        autonomy?.tooling.forgetOwner(this);
      }
      await _gateway.dispose();
    }
  }
}

/// Exact-content diagnostic request. No task, tools, output cap or retries.
InferenceRequest buildProjectionDiagnosticRequest(
  Map<String, dynamic> command,
) {
  if (command['model'] != 'gpt-6-luna') {
    throw const FormatException('projection_luna_required');
  }
  if (command['reasoningEffort'] != 'low') {
    throw const FormatException('explicit_low_reasoning_required');
  }
  if (command['cloudConsent'] != true) {
    throw const FormatException('explicit_cloud_consent_required');
  }
  final mode = command['mode'];
  if (mode != 'baseline' &&
      mode != 'explicit' &&
      mode != 'prewarm' &&
      mode != 'message_boundary') {
    throw const FormatException('projection_mode_required');
  }
  final stable = command['stableText'];
  final suffix = command['volatileSuffix'];
  if (stable is! String || stable.isEmpty) {
    throw const FormatException('stableText_required');
  }
  if (suffix is! String) {
    throw const FormatException('volatileSuffix_required');
  }
  if (mode == 'prewarm' && suffix.isNotEmpty) {
    throw const FormatException('prewarm_suffix_must_be_empty');
  }
  final intent = ContextCacheIntent(
    writeAfterSegmentIds: mode == 'explicit' ? ['input[0].content[0]'] : [],
    lookupAfterSegmentIds: mode == 'explicit' ? ['input[0].content[0]'] : [],
  );
  var request =
      ResponsesInput([
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': stable},
            if (mode == 'baseline' || mode == 'explicit')
              {'type': 'input_text', 'text': suffix},
          ],
        },
        if (mode == 'message_boundary')
          {
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': suffix},
            ],
          },
      ]).attach(
        InferenceRequest(
          prompt: '',
          systemPrompt: 'Reply exactly OK',
          reasoningEffort: 'low',
          metadata: {
            contextCacheIntentMetadataKey: intent.toJson(),
            if (command.containsKey('comparisonResponseId'))
              contextCacheComparisonMetadataKey: ContextCacheComparisonRequest(
                baselineResponseId: command['comparisonResponseId'] as String,
              ).toJson(),
          },
        ),
      );
  final sessionJson = command['sessionSpec'];
  if (sessionJson != null) {
    final spec = InferenceSessionSpec.fromJson(
      Map<String, Object?>.from(sessionJson as Map),
    );
    request = spec.attach(
      request,
      turn: command['turnId'] == null
          ? null
          : InferenceTurnSpec(id: command['turnId'] as String),
    );
    final affinity = command['affinity'] ?? 'cache_key';
    if (!const {'cache_key', 'session', 'turn'}.contains(affinity)) {
      throw const FormatException('projection_affinity_invalid');
    }
    if (affinity == 'turn' && command['turnId'] == null) {
      throw const FormatException('inference_turn_required');
    }
    request = OpenAiSessionOptions(
      sessionAffinity: affinity != 'cache_key',
      turnAffinity: affinity == 'turn',
    ).attach(request);
  } else if (command.containsKey('affinity') || command.containsKey('turnId')) {
    throw const FormatException('inference_session_required');
  }
  return request;
}
