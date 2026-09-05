import 'dart:async';
import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
// ADR 0026: the in-process ACP transport lives in the HOST package
// (HarnessEmbed); this module keeps product-side policy only: config
// (backend switching, check override) + consent (PendingPermission).
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';
// ADR 0026: providers register HarnessBackendBinding entries; the client
// is pure inference_core underneath.
import 'package:xsoulspace_inference_apple_foundation/xsoulspace_inference_apple_foundation.dart'
    show appleFoundationBinding;
import 'package:xsoulspace_inference_openrouter/xsoulspace_inference_openrouter.dart'
    show OpenRouterInferenceClient, OpenRouterModelNames;

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
  final _permissionController = StreamController<PendingPermission>.broadcast();
  Completer<PendingPermission>? _permissionSeen;

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
  }) => _requireEmbed().delegateTask(
    sessionId,
    task,
    onText: onText,
    onToolCall: onToolCall,
  );

  /// Cancels in-flight work for a session (real: aborts generation).
  void cancel(final String sessionId) => _embed?.cancel(sessionId);

  /// Stops the daemon (closes both channel ends) and the client.
  Future<void> stop() async {
    final embed = _embed;
    _embed = null;
    await embed?.stop();
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
    _permissionSeen?.complete(pending);
    _permissionController.add(pending);
    return pending.future;
  }
}

/// A permission request awaiting the user's (or test's) decision. Exactly
/// one answer is honored; a second call is a no-op.
final class PendingPermission {
  PendingPermission._(this.request);

  final AcpPermissionRequest request;
  final Completer<AcpPermissionOutcome> _completer =
      Completer<AcpPermissionOutcome>();

  Future<AcpPermissionOutcome> get future => _completer.future;
  bool get isAnswered => _completer.isCompleted;

  void allow() => _answer(AcpPermissionOutcome.allow);
  void reject() => _answer(AcpPermissionOutcome.reject);

  void _answer(final AcpPermissionOutcome outcome) {
    if (!_completer.isCompleted) _completer.complete(outcome);
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
    this.meaningProfile = false,
    this.scripted = false,
    this.handlerFactory,
    this.apiKey,
    this.checkCommand,
  });

  /// `apple_foundation_afm` (local-first, North Star) or `open_router`.
  final String backend;
  final String model;
  final bool meaningProfile;
  final bool scripted;
  final GenerationHandler Function(ModelRouter router)? handlerFactory;

  /// Explicit OpenRouter API key; null → `OPENROUTER_API_KEY` in the
  /// process environment (never present for a GUI-launched macOS app).
  final String? apiKey;

  /// Explicit verification criterion overriding the D8 workspace
  /// convention (the doc binding's `--check`, ADR 0003). Empty/null → the
  /// workspace convention decides.
  final List<String>? checkCommand;

  /// The OpenRouter router needs a key from somewhere; AFM needs nothing
  /// (on-device). Honest failure: an unresolvable key is a config error
  /// surfaced BEFORE a session is created, never a mid-turn crash.
  bool get openRouterKeyResolvable {
    if (backend != 'open_router') return true;
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
      final router = ModelRouter(
        inferenceClientsBuilders: {
          OpenRouterModelNames.openRouter: () => OpenRouterInferenceClient(
                apiKey: key,
                defaultModel: model,
              ),
        },
      )
        ..models[const ModelId('harnessd')] = Model(
          id: const ModelId('harnessd'),
          name: OpenRouterModelNames.openRouter,
        );
      bindings['open_router'] = HarnessBackendBinding(
        defaultModel: model,
        buildRouter: ({required model, apiKey}) => router,
      );
    }
    if (backend == 'apple_foundation_afm') {
      bindings['apple_foundation_afm'] = appleFoundationBinding().binding;
    }
    return HarnessAcpBackend(
      backend: backend,
      bindings: bindings,
      model: model,
      meaningProfile: meaningProfile,
      scripted: scripted,
      handlerFactory: handlerFactory,
      apiKey: apiKey,
      checkCommand: checkCommand,
    );
  }

  /// Backend-switch support: same mover surface, new backend/key/check.
  HarnessHostConfig copyWith({
    String? backend,
    String? apiKey,
    List<String>? checkCommand,
  }) => HarnessHostConfig(
    backend: backend ?? this.backend,
    model: model,
    meaningProfile: meaningProfile,
    scripted: scripted,
    handlerFactory: handlerFactory,
    apiKey: apiKey ?? this.apiKey,
    checkCommand: checkCommand ?? this.checkCommand,
  );
}
