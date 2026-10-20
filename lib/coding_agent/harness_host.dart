import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
// ADR 0036: composition root is xsoulspace_agentic_afm; the FFI client
// stays in xsoulspace_inference_apple_foundation.
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart'
    show
        InferenceClientBinding,
        JevClientBinding,
        NativeTextClientBinding,
        appleFoundationBinding;
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
// ADR 0026: the in-process ACP transport lives in the HOST package
// (HarnessEmbed); this module keeps product-side policy only: config
// (backend switching, check override) + consent (PendingPermission).
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
import 'package:xsoulspace_inference_acp/xsoulspace_inference_acp.dart'
    show AcpInferenceClient, AcpSessionPersistence;
import 'package:xsoulspace_inference_openrouter/xsoulspace_inference_openrouter.dart'
    show OpenRouterInferenceClient, OpenRouterModelNames;

/// Model-name key for the external-ACP harness backend: the external agent
/// process IS the generator; all tool execution stays inside the harness
/// (ADR 0012 review boundary — the workspace owner materializes writes).
enum ExternalAcpModelNames implements ModelName { externalAcp }

/// TASK B (ADR 0015) — last_answer embeds the harness as its first domain
/// host. This module owns the daemon lifecycle IN-PROCESS via the host
/// package's [HarnessEmbed] (ADR 0025/0026):
///
/// - per-session worlds and per-workspace snapshot stores
///   (`<cwd>/.dart_tool/harnessd_store`) are owned by the backend — the
///   host never touches them (the snapshot persists beats/verdicts/budgets
///   only; the meaning tree re-derives, ADR 0023 §2);
/// - multiplayer-ready by construction (ADR 0015): the user's task input is
///   a HOST-INJECTED DECISION (`session/prompt`), and their write approvals
///   ride the EXISTING `session/request_permission` round-trip. No second
///   protocol is invented anywhere.
///
/// The backend is deny-by-default: with no permission delegate attached
/// there is NO approval path (every write is rejected), never an
/// unconditional allow.
final class HarnessHost {
  HarnessHost({required this.config});

  final HarnessHostConfig config;

  HarnessEmbed? _embed;
  HarnessAcpBackend? _backend;
  final _meaningTasks = <String, Map<String, Object?>>{};
  // Receipt IDs survive process restarts in the native world journal.
  final _actionEpoch = '${DateTime.now().microsecondsSinceEpoch}-$pid';
  int _meaningRequest = 0;
  final _permissionController = StreamController<PendingPermission>.broadcast();
  Completer<PendingPermission>? _permissionSeen;
  final _pendingPermissions = <PendingPermission>{};

  /// Whether the in-process daemon is running and initialized.
  bool get isRunning => _embed?.isRunning ?? false;

  /// Every `session/request_permission` the daemon raises mid-turn (the
  /// write gate / edit approver). The UI (or the user-as-actor) answers via
  /// [PendingPermission.allow] / [PendingPermission.reject].
  Stream<PendingPermission> get permissionRequests =>
      _permissionController.stream;

  /// Starts the daemon + client handshake. Idempotent.
  Future<void> start() async {
    if (isRunning) return;
    final backend = config.buildBackend();
    _backend = backend;
    _embed = await HarnessEmbed.start(
      backend: backend,
      permissionHandler: _handlePermission,
    );
  }

  /// Creates a session for [cwd] (the delegated workspace). Sessions are
  /// keyed per workspace by the backend: a second `session/new` for the
  /// same cwd CONTINUES the live world (and restores it from the snapshot
  /// store after a host restart).
  Future<String> newSession(final String cwd) =>
      _requireEmbed().newSession(cwd);

  /// Runs one prompt turn — the user's task sentence as a host-injected
  /// decision. Progress streams to [onText] (agent text chunks, including
  /// the final `verdict:` line) and [onToolCall] (tool titles).
  Future<AcpStopReason> delegateTask(
    final String sessionId,
    final String task, {
    final void Function(String delta)? onText,
    final void Function(String title)? onToolCall,
    final void Function(CodingHostUpdate update)? onHostUpdate,
  }) async {
    try {
      return await _requireEmbed().delegateTask(
        sessionId,
        task,
        onText: onText,
        onToolCall: onToolCall,
        onHostUpdate: onHostUpdate,
      );
    } finally {
      _retireSettledPermissions(sessionId);
    }
  }

  /// Cancels in-flight work for a session (real: aborts generation).
  void cancel(final String sessionId) => _embed?.cancel(sessionId);

  /// Existing world conversation ingress admits a sibling actor while coding
  /// continues. It does not create another provider loop or editing authority.
  Future<SessionPromptResult> converse(String sessionId, String text) =>
      _backend!.converseSession(sessionId, text);

  Map<String, Object?>? meaningReviewProposal(String sessionId) =>
      _backend?.registry.sessions[sessionId]?.state.reviewProposal;

  /// The bounded experiment uses the existing installed-action SDK and pump.
  /// Display JSON supplies no authority; the host retains the issued proposal.
  Future<Map<String, Object?>> meaningAction(
    final String sessionId,
    final String action,
    final Map<String, Object?> arguments,
  ) async {
    try {
      return await _invokeMeaningAction(sessionId, action, arguments);
    } finally {
      _retireSettledPermissions(sessionId);
    }
  }

  /// Conventional candidates use the same actor admission, installed-action
  /// pump and exact native consent as semantic changes. This adapter never
  /// receives a filesystem writer or reconstructs authority from display JSON.
  Future<Map<String, Object?>> conventionalAction(
    final String sessionId,
    final String action,
    final Map<String, Object?> arguments,
  ) async {
    try {
      return await _invokeMeaningAction(
        sessionId,
        action,
        arguments,
        toolName: 'conventional_change',
      );
    } finally {
      _retireSettledPermissions(sessionId);
    }
  }

  /// Native admission held by this product host, never a task ID accepted from
  /// a displayed receipt. The extension still checks its caller, project,
  /// artifact/journal provenance, revisions and exact consent independently.
  bool admitsSavedCodeReview(HostToolExtensionContext context) {
    if (!isRunning ||
        _backend == null ||
        !context.isCurrent ||
        !context.isCallerBound) {
      return false;
    }
    return _meaningTasks.entries.any(
      (entry) =>
          entry.key.startsWith('conventional_change:') &&
          entry.value['taskId'] == context.taskId,
    );
  }

  Future<Map<String, Object?>> _invokeMeaningAction(
    final String sessionId,
    final String action,
    final Map<String, Object?> arguments, {
    final String toolName = 'meaning_span_change',
  }) async {
    final backend = _backend;
    if (backend == null || !isRunning) {
      return {'ok': false, 'error': 'meaning_session_unavailable'};
    }
    final tools = HarnessAgentTools(backend: backend);
    final conventional = toolName == 'conventional_change';
    final actor = conventional
        ? 'lastanswer-human-coding-$sessionId'
        : 'lastanswer-human-meaning-$sessionId';
    final identity = <String, Object?>{'docId': sessionId, 'actor': actor};
    final taskKey = conventional ? '$toolName:$sessionId' : sessionId;
    var task = _meaningTasks[taskKey];
    if (task == null) {
      final joined = await tools.context({...identity, 'op': 'join'});
      if (joined['ok'] != true) return joined;
      final oriented = await tools.context({
        ...identity,
        'op': 'orient',
        'query': conventional
            ? 'Inspect the admitted code workspace and reversible candidate.'
            : 'Inspect the explicitly bound greeting experiment.',
      });
      if (oriented['ok'] != true) return oriented;
      task = conventional
          ? await backend.activeExternalActorTask(sessionId, actorId: actor)
          : null;
      task ??= conventional
          ? await backend.admitExternalTaskFromSentence(
              sessionId,
              actorId: actor,
              requestId: 'meaning-enroll-$_actionEpoch-${++_meaningRequest}',
              task:
                  'Review the admitted code candidate, verify it, '
                  'request exact consent and preserve native Undo. '
                  'No live shell authoring.',
              eagerMeaningScan: false,
            )
          : await tools.taskAdmitExternal({
              ...identity,
              'requestId': 'meaning-enroll-$_actionEpoch-${++_meaningRequest}',
              'task':
                  'Append the selected greeting suffix using an executed '
                  'preview; preserve exact native rollback.',
            });
      if (task['ok'] != true) return task;
      _meaningTasks[taskKey] = task;
    }
    Future<Map<String, Object?>> invoke(
      String name,
      Map<String, Object?> args,
    ) async {
      final actions = await tools.participation({
        ...identity,
        'op': 'actions',
        'toolDetail': true,
        'toolLimit': 128,
      });
      if (actions['ok'] != true) return actions;
      final menu = actions['toolMenu']! as Map;
      if (!(menu['tools'] as List).any(
        (entry) => (entry as Map)['name'] == name,
      )) {
        return {'ok': false, 'error': 'meaning_tool_unavailable', 'tool': name};
      }
      final receipt = await tools.participation({
        ...identity,
        'op': 'tool_action',
        'taskId': task!['taskId'],
        'thread': task['admissionBeatId'],
        'requestId': 'meaning-action-$_actionEpoch-${++_meaningRequest}',
        'toolName': name,
        'toolRevision': menu['revision'],
        'arguments': args,
      });
      if (receipt['ok'] != true) return receipt;
      return readHarnessToolReceipt(
        receipt: receipt,
        toolName: name,
        readContext: (page) => tools.context({...identity, ...page}),
      );
    }

    if (!conventional && action == 'ground') {
      final scan = await invoke('repo_etl', {'action': 'scan'});
      if (scan['ok'] != true) return scan;
      final ground = await invoke('meaning_span_change', {'action': action});
      if (ground['ok'] != true) return ground;
      final binding = ground['binding']! as Map;
      final read = await invoke('meaning_program', {
        'ops': [
          {
            'op': 'read',
            'focusId': binding['symbolId'] ?? binding['symbol_id'],
            'budget': 2048,
          },
        ],
      });
      if (read['ok'] != true) return read;
      return ground;
    }
    return invoke(toolName, {...arguments, 'action': action});
  }

  /// Stops the daemon (closes both channel ends) and the client.
  Future<void> stop({HarnessHostConfig? retaining}) async {
    for (final pending in [..._pendingPermissions]) {
      pending.reject();
    }
    final embed = _embed;
    _embed = null;
    _backend = null;
    _meaningTasks.clear();
    await embed?.stop();
    if (!identical(config.jevBinding, retaining?.jevBinding)) {
      await config.jevBinding?.dispose();
    }
    if (!identical(config.layaBinding, retaining?.layaBinding)) {
      await config.layaBinding?.dispose();
    }
    if (!identical(config.lfmBinding, retaining?.lfmBinding)) {
      await config.lfmBinding?.settleAndDispose();
    }
    if (!identical(config.qwenBinding, retaining?.qwenBinding)) {
      await config.qwenBinding?.settleAndDispose();
    }
    if (!_permissionController.isClosed) await _permissionController.close();
  }

  HarnessEmbed _requireEmbed() {
    final embed = _embed;
    if (embed == null || !embed.isRunning) {
      throw StateError('Harness host is not running: call start() first');
    }
    return embed;
  }

  /// Test visibility: completes with the NEXT pending permission request
  /// (or the one already waiting).
  Future<PendingPermission> nextPermission({
    final Duration timeout = const Duration(seconds: 60),
  }) {
    final seen = _permissionSeen;
    if (seen != null && seen.isCompleted) return seen.future;
    final completer = Completer<PendingPermission>();
    _permissionSeen = completer;
    return completer.future.timeout(timeout);
  }

  Future<AcpPermissionOutcome> _handlePermission(
    final AcpPermissionRequest request,
  ) {
    final pending = PendingPermission._(request);
    if (pending.isAnswered) return pending.future;
    _pendingPermissions.add(pending);
    unawaited(pending.future.then((_) => _pendingPermissions.remove(pending)));
    _permissionSeen?.complete(pending);
    _permissionController.add(pending);
    return pending.future;
  }

  // Native gates own cancellation/deadlines. Retire a terminal operation's
  // unanswered client round-trip, never a newer active native wait.
  void _retireSettledPermissions(String sessionId) {
    if (_backend?.hasPendingPermission(sessionId) == true) {
      return;
    }
    for (final pending in [..._pendingPermissions]) {
      if (pending.request.sessionId == sessionId && !pending.isAnswered) {
        pending.reject();
      }
    }
  }
}

/// Decode a native receipt without replaying its action. The caller binds
/// [readContext] to the same authenticated document/actor as the original call.
/// Pages select the original stored output, never its indexed display text.
Future<Map<String, Object?>> readHarnessToolReceipt({
  required Map<String, Object?> receipt,
  required String toolName,
  required Future<Map<String, Object?>> Function(Map<String, Object?>)
  readContext,
}) async {
  if (receipt['ok'] != true) return receipt;
  Map<String, Object?> invalid(String detail) => {
    'ok': false,
    'error': 'meaning_receipt_page_invalid',
    'detail': detail,
    'receipt': receipt,
  };
  Object? output = receipt['output'];
  final omitted = receipt['outputOmitted'] == true;
  if (omitted) {
    final beat = receipt['resultBeat'];
    final bytes = receipt['outputBytes'];
    if (beat is! String || beat.isEmpty) return invalid('result_beat_missing');
    if (bytes is! int || bytes < 0) return invalid('output_bytes_invalid');
    final joined = StringBuffer();
    var offset = 0;
    int? total;
    while (true) {
      final page = await readContext({
        'op': 'read',
        'beat': beat,
        'field': 'tool_output',
        'offset': offset,
        'limit': 32768,
      });
      // Preserve the native denial; it grants no retry/replay of the action.
      if (page['ok'] == false) return page;
      if (page['ok'] != true) return invalid('page_status_missing');
      if (page['beatId'] != beat) return invalid('result_beat_mismatch');
      if (page['field'] != 'tool_output') return invalid('field_mismatch');
      if (page['toolName'] != toolName) return invalid('tool_name_mismatch');
      if (page['offsetUnit'] != 'utf16_code_units') {
        return invalid('offset_unit_mismatch');
      }
      if (page['offset'] is! int || page['offset'] != offset) {
        return invalid('offset_mismatch');
      }
      final length = page['totalLength'];
      if (length is! int || length < offset) {
        return invalid('total_length_invalid');
      }
      if (total != null && total != length) {
        return invalid('total_length_changed');
      }
      total = length;
      final text = page['text'];
      if (text is! String || text.length > 32768) {
        return invalid('page_text_invalid');
      }
      final end = offset + text.length;
      if (end > length) return invalid('page_exceeds_total');
      final truncated = page['truncated'];
      if (truncated is! bool) return invalid('truncated_flag_invalid');
      if (truncated) {
        if (end <= offset ||
            end >= length ||
            page['nextOffset'] is! int ||
            page['nextOffset'] != end) {
          return invalid('next_offset_invalid');
        }
      } else if (end != length || page.containsKey('nextOffset')) {
        return invalid('terminal_incomplete');
      }
      joined.write(text);
      if (!truncated) break;
      offset = end;
    }
    // A page may end between UTF-16 surrogates. Encode only after joining.
    output = joined.toString();
    if (utf8.encode(output as String).length != bytes) {
      return invalid('output_bytes_mismatch');
    }
  }
  if (output is! String) {
    return {
      'ok': false,
      'error': 'meaning_receipt_payload_unavailable',
      'receipt': receipt,
    };
  }
  Object? decoded;
  if (omitted) {
    try {
      decoded = jsonDecode(output);
    } on FormatException {
      return invalid('json_invalid');
    }
  } else {
    decoded = jsonDecode(output);
  }
  if (decoded is! Map) {
    return {
      'ok': false,
      'error': 'meaning_receipt_invalid',
      'receipt': receipt,
    };
  }
  return {...Map<String, Object?>.from(decoded), 'receipt': receipt};
}

/// A permission request awaiting the user's (or test's) decision. Exactly
/// one answer is honored; a second call is a no-op.
final class PendingPermission {
  PendingPermission._(this.request) {
    final expiresAt = request.expiresAt;
    if (expiresAt != null) {
      final remaining = expiresAt.difference(DateTime.now().toUtc());
      if (remaining <= Duration.zero) {
        _finish(AcpPermissionOutcome.cancelled);
      } else {
        // Mirror the native owner's absolute expiry. No new timeout policy.
        _expiry = Timer(
          remaining,
          () => _finish(AcpPermissionOutcome.cancelled),
        );
      }
    }
  }

  final AcpPermissionRequest request;
  final Completer<AcpPermissionOutcome> _completer =
      Completer<AcpPermissionOutcome>();
  Timer? _expiry;

  Future<AcpPermissionOutcome> get future => _completer.future;
  bool get isAnswered {
    if (request.expiresAt case final expiry?) {
      if (!DateTime.now().toUtc().isBefore(expiry)) {
        _finish(AcpPermissionOutcome.cancelled);
      }
    }
    return _completer.isCompleted;
  }

  /// False means the wait already settled or its native deadline expired.
  bool allow() => _answer(AcpPermissionOutcome.allow);
  bool reject() => _answer(AcpPermissionOutcome.reject);

  bool _answer(final AcpPermissionOutcome outcome) {
    if (isAnswered) return false;
    _finish(outcome);
    return true;
  }

  void _finish(AcpPermissionOutcome outcome) {
    if (_completer.isCompleted) return;
    _expiry?.cancel();
    _completer.complete(outcome);
  }
}

/// Configuration for the embedded daemon. The backend is switchable at
/// runtime (AFM on-device ↔ OpenRouter): a switch restarts the daemon and
/// the per-workspace snapshot store restores the world on the next session
/// (R7c `loadSession`), so work continues across the switch. Tests pass
/// [handlerFactory] — the harness's LLM-free scripted seam.
final class HarnessHostConfig {
  const HarnessHostConfig({
    this.backend = 'apple_foundation_afm',
    this.model = 'deepseek/deepseek-v4-flash-0731',
    this.actorContextOrder = ActorContextOrder.legacy,
    this.meaningProfile = false,
    this.scripted = false,
    this.handlerFactory,
    this.causalTrace,
    this.jevBinding,
    this.layaBinding,
    this.lfmBinding,
    this.qwenBinding,
    this.inferenceBinding,
    this.routedBinding,
    this.apiKey,
    this.checkCommand,
    this.externalAcpCommand,
    this.externalAcpArguments = const [],
    this.externalAcpEnvironment,
    this.externalAcpWorkingDirectory,
    this.externalAcpClientServices,
    this.externalAcpConversationKey,
    this.externalAcpClientFactory,
    this.externalAcpMcpServers,
    this.externalAcpSessionPersistence,
    this.externalAcpProviderIdentity,
    this.extraToolsWithContext,
    this.actorToolNames,
  });

  /// `apple_foundation_afm`, `open_router`, opt-in `jev`, opt-in local
  /// `laya` (a laya-serve System One endpoint on this machine), opt-in
  /// local text casts `lfm` / `qwen` (ADR 0059 — lazy in-process native
  /// engines, macOS only), or `external_acp` (a user-registered ACP
  /// agent process from the agent config used as the harness's
  /// generator).
  final String backend;
  final String model;

  /// Opt-in serialization order over the same authorized actor cut.
  final ActorContextOrder actorContextOrder;
  final bool scripted;
  final GenerationHandler Function(ModelRouter router)? handlerFactory;

  /// Optional existing body-free stage observer. It grants no execution or
  /// acceptance authority and is retained when a document changes backend.
  final CausalTraceSink? causalTrace;

  final JevClientBinding? jevBinding;

  /// Opt-in local decision capability (`laya` backend): a `layaDecisionBinding`
  /// bound to a laya-compatible System One endpoint on this machine. No key,
  /// no consent gate — local-only policy admits it via capability facts.
  final JevClientBinding? layaBinding;

  /// ADR 0059 — opt-in local text casts (`lfm` / `qwen` backends): lazy
  /// in-process native engines (`MlxNativeTextClient` behind the afm
  /// composition root's bindings). No key, no consent gate — loopback /
  /// in-process only; weights load on the first cast and an absent cached
  /// snapshot surfaces as typed unavailability at use time, never a hang.
  final NativeTextClientBinding? lfmBinding;
  final NativeTextClientBinding? qwenBinding;

  /// Device-owned request provider, scoped to this host/session lifetime.
  final InferenceClientBinding? inferenceBinding;

  /// Optional host-composed generator resource; its dispatch receipts identify
  /// the actual local/escalated provider. This does not change actor authority.
  final HarnessBackendBinding? routedBinding;

  /// Explicit OpenRouter API key; null → `OPENROUTER_API_KEY` in the
  /// process environment (never present for a GUI-launched macOS app).
  final String? apiKey;

  /// External-ACP backend launch parameters (from the agent config's
  /// registered servers). Empty command = backend unavailable; the daemon
  /// then refuses prompts with named data instead of hanging.
  final String? externalAcpCommand;
  final List<String> externalAcpArguments;
  final Map<String, String>? externalAcpEnvironment;
  final List<ToolDef> Function(HostToolExtensionContext context)?
  extraToolsWithContext;

  /// Host-selected subset; the harness refuses names outside admitted tools.
  final Set<ToolName>? actorToolNames;
  final String? externalAcpWorkingDirectory;
  final AcpClientServices? externalAcpClientServices;

  /// Explicit document/participant conversation identity. Transport restarts
  /// resume this conversation; provider/model names never stand in for it.
  final String? externalAcpConversationKey;
  final Future<AcpClient> Function()? externalAcpClientFactory;
  final List<Map<String, Object?>> Function(ToolRegistry registry)?
  externalAcpMcpServers;
  final AcpSessionPersistence? externalAcpSessionPersistence;
  final String? externalAcpProviderIdentity;

  /// Explicit verification criterion overriding the D8 workspace
  /// convention (the doc binding's `--check`, ADR 0003). Empty/null → the
  /// workspace convention decides.
  final List<String>? checkCommand;

  /// R9.1 (redefined plan): the embedded runtime is the MEANING runtime
  /// (ADR 0023/0024/0027) — reads are budgeted zoom cuts, mutations are
  /// host-materialized edit moves that verify and auto-revert; blind
  /// whole-file writes do not exist. AFM's context window is too small
  /// for anything else; the conventional command profile remains only for
  /// external CLI squad members (codex et al., R9.c's runtime union).
  /// NOT a constructor default: the AGENT-DOC SURFACE derives
  /// `meaningProfile: true` for its bindings (scripted test seams keep
  /// the conventional registry, whose tools the scripted mover emits).
  final bool meaningProfile;

  /// R7c of the external-ACP lane: an unresolvable command is a config
  /// error surfaced BEFORE a session is created, never a mid-turn crash.
  bool get openRouterKeyResolvable {
    if (backend == 'external_acp') {
      final command = externalAcpCommand;
      return command != null && command.isNotEmpty;
    }
    if (backend != 'open_router' && backend != 'jev') return true;
    final key = apiKey ?? Platform.environment['OPENROUTER_API_KEY'];
    return key != null && key.isNotEmpty;
  }

  /// ADR 0025 seam: backends are INJECTED bindings — AFM (retained client
  /// so cancel reaches `xs_fm_cancel`) and OpenRouter (needs a key). An
  /// unresolvable backend yields no binding; the daemon then refuses
  /// prompts with named data instead of hanging. Bindings are LAZY — the
  /// native client / HTTP client materialize on first router use, so
  /// scripted / handler-factory modes never touch a provider.
  HarnessAcpBackend buildBackend() {
    final bindings = <String, HarnessBackendBinding>{};
    final key = apiKey ?? Platform.environment['OPENROUTER_API_KEY'];
    if (backend == 'open_router' && key != null && key.isNotEmpty) {
      final router =
          ModelRouter(
              inferenceClientsBuilders: {
                OpenRouterModelNames.openRouter: () =>
                    OpenRouterInferenceClient(apiKey: key, defaultModel: model),
              },
            )
            ..models[const ModelId('harnessd')] = const Model(
              id: ModelId('harnessd'),
              name: OpenRouterModelNames.openRouter,
            );
      bindings['open_router'] = HarnessBackendBinding(
        defaultModel: model,
        buildRouter: ({required model, apiKey}) => router,
      );
    }
    if (backend == 'apple_foundation_afm') {
      final afm = appleFoundationBinding().binding;
      // The binding's input profile is a REAL-model guard (on-device
      // context window minus generation reserve). An LLM-free run never
      // reaches a model, and the rendered decision surface (tool menu +
      // context cut) exceeds that profile, so the ADR 0020 input gate
      // would bounce every decision before any move — the harness's own
      // convention for model-less providers is no input limit
      // (test_provider). Real-model runs keep the profile.
      bindings['apple_foundation_afm'] = handlerFactory == null
          ? afm
          : HarnessBackendBinding(
              defaultModel: afm.defaultModel,
              buildRouter: afm.buildRouter,
              cancelActiveGeneration: afm.cancelActiveGeneration,
            );
    }
    if (backend == 'jev' && jevBinding != null) {
      bindings['jev'] = jevBinding!.binding;
    }
    if (backend == 'laya' && layaBinding != null) {
      bindings['laya'] = layaBinding!.binding;
    }
    if (backend == 'lfm' && lfmBinding != null) {
      bindings['lfm'] = lfmBinding!.binding;
    }
    if (backend == 'qwen' && qwenBinding != null) {
      bindings['qwen'] = qwenBinding!.binding;
    }
    final externalCommand = externalAcpCommand;
    if (backend == 'external_acp' && (externalCommand?.isNotEmpty ?? false)) {
      final command = externalAcpCommand!;
      final client = AcpInferenceClient(
        command: command,
        arguments: externalAcpArguments,
        workingDirectory: externalAcpWorkingDirectory,
        environment: externalAcpEnvironment,
        clientServices: externalAcpClientServices,
        conversationKey: externalAcpConversationKey,
        clientFactory: externalAcpClientFactory,
        boundMcpServers: externalAcpMcpServers,
        sessionPersistence: externalAcpSessionPersistence,
        providerIdentity: externalAcpProviderIdentity,
      );
      final router =
          ModelRouter(
              inferenceClientsBuilders: {
                ExternalAcpModelNames.externalAcp: () => client,
              },
            )
            ..models[const ModelId('harnessd')] = const Model(
              id: ModelId('harnessd'),
              name: ExternalAcpModelNames.externalAcp,
            );
      bindings['external_acp'] = HarnessBackendBinding(
        defaultModel: model,
        buildRouter: ({required model, apiKey}) => router,
        cancelActiveGeneration: client.cancelActive,
      );
    }
    return HarnessAcpBackend(
      typedTextUpdates: true,
      causalTrace: causalTrace,
      actorContextOrder: actorContextOrder,
      // The trusted product composition injects this provider; document
      // backend labels carry no credential or execution authority.
      backend: backend,
      bindings: {
        ...bindings,
        if (routedBinding != null)
          backend: routedBinding!
        else if (inferenceBinding != null)
          backend: inferenceBinding!.binding,
      },
      model: model,
      meaningProfile: meaningProfile,
      scripted: scripted,
      handlerFactory: handlerFactory,
      apiKey: apiKey,
      checkCommand: checkCommand,
      extraToolsWithContext: extraToolsWithContext,
      actorToolNames: actorToolNames,
    );
  }

  /// Backend-switch support: same mover surface, new backend/key/check.
  HarnessHostConfig copyWith({
    List<ToolDef> Function(HostToolExtensionContext)? extraToolsWithContext,
    bool clearExtraToolsWithContext = false,
    Set<ToolName>? actorToolNames,
    bool clearActorToolNames = false,
    String? backend,
    String? model,
    ActorContextOrder? actorContextOrder,
    String? apiKey,
    bool clearApiKey = false,
    bool clearJevBinding = false,
    bool clearLayaBinding = false,
    bool clearLfmBinding = false,
    bool clearQwenBinding = false,
    bool clearInferenceBinding = false,
    List<String>? checkCommand,
    bool? meaningProfile,
    JevClientBinding? jevBinding,
    JevClientBinding? layaBinding,
    NativeTextClientBinding? lfmBinding,
    NativeTextClientBinding? qwenBinding,
    InferenceClientBinding? inferenceBinding,
    HarnessBackendBinding? routedBinding,
    bool clearRoutedBinding = false,
    String? externalAcpCommand,
    List<String>? externalAcpArguments,
    Map<String, String>? externalAcpEnvironment,
    String? externalAcpWorkingDirectory,
    AcpClientServices? externalAcpClientServices,
    String? externalAcpConversationKey,
    Future<AcpClient> Function()? externalAcpClientFactory,
    List<Map<String, Object?>> Function(ToolRegistry)? externalAcpMcpServers,
    AcpSessionPersistence? externalAcpSessionPersistence,
    String? externalAcpProviderIdentity,
  }) => HarnessHostConfig(
    backend: backend ?? this.backend,
    model: model ?? this.model,
    actorContextOrder: actorContextOrder ?? this.actorContextOrder,
    meaningProfile: meaningProfile ?? this.meaningProfile,
    scripted: scripted,
    handlerFactory: handlerFactory,
    causalTrace: causalTrace,
    jevBinding: clearJevBinding ? null : jevBinding ?? this.jevBinding,
    layaBinding: clearLayaBinding ? null : layaBinding ?? this.layaBinding,
    lfmBinding: clearLfmBinding ? null : lfmBinding ?? this.lfmBinding,
    qwenBinding: clearQwenBinding ? null : qwenBinding ?? this.qwenBinding,
    inferenceBinding: clearInferenceBinding
        ? null
        : inferenceBinding ?? this.inferenceBinding,
    routedBinding: clearRoutedBinding
        ? null
        : routedBinding ?? this.routedBinding,
    apiKey: clearApiKey ? null : apiKey ?? this.apiKey,
    checkCommand: checkCommand ?? this.checkCommand,
    externalAcpCommand: externalAcpCommand ?? this.externalAcpCommand,
    externalAcpArguments: externalAcpArguments ?? this.externalAcpArguments,
    externalAcpEnvironment:
        externalAcpEnvironment ?? this.externalAcpEnvironment,
    externalAcpWorkingDirectory:
        externalAcpWorkingDirectory ?? this.externalAcpWorkingDirectory,
    externalAcpClientServices:
        externalAcpClientServices ?? this.externalAcpClientServices,
    externalAcpConversationKey:
        externalAcpConversationKey ?? this.externalAcpConversationKey,
    externalAcpClientFactory:
        externalAcpClientFactory ?? this.externalAcpClientFactory,
    externalAcpMcpServers: externalAcpMcpServers ?? this.externalAcpMcpServers,
    externalAcpSessionPersistence:
        externalAcpSessionPersistence ?? this.externalAcpSessionPersistence,
    externalAcpProviderIdentity:
        externalAcpProviderIdentity ?? this.externalAcpProviderIdentity,
    actorToolNames: clearActorToolNames
        ? null
        : actorToolNames ?? this.actorToolNames,
    extraToolsWithContext: clearExtraToolsWithContext
        ? null
        : extraToolsWithContext ?? this.extraToolsWithContext,
  );
}
