import 'package:file_selector/file_selector.dart';
import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';
import 'package:lastanswer/doc/acp_agent_runtime_registry.dart';
import 'package:lastanswer/doc/chat_permission_policy.dart';
import 'package:lastanswer/doc/chat_inference_resolver.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

hc.NodeId _nextNodeId() => hc.NodeId(_uuid.v4());

/// One selectable transport for the chat: an ACP agent process (catalog
/// install, config-registered server, or a picked local executable) or a
/// hosted chat-completions model from the agent config.
sealed class ChatTransport {
  const ChatTransport();

  String get label;
  String get pickerKey;
}

final class AcpChatTransport extends ChatTransport {
  const AcpChatTransport({
    required this.agentKey,
    required this.label,
    this.installation,
    this.config,
  });

  /// Stable identity for per-doc runtime restarts on agent switch.
  final String agentKey;
  @override
  final String label;
  final AcpAgentInstallation? installation;
  final AcpRuntimeConfig? config;

  @override
  String get pickerKey => 'acp:$agentKey';
}

final class HostedChatTransport extends ChatTransport {
  const HostedChatTransport({required this.providerId, required this.model});

  final String providerId;
  final String model;

  @override
  String get label => '$providerId · $model';

  @override
  String get pickerKey => 'hosted:$providerId:$model';
}

class ChatDocumentView extends StatefulWidget {
  const ChatDocumentView({required this.doc, super.key});

  final ProjectModelDoc doc;

  /// The OPEN chat surface's multiplayer link — the shell's sync-cycle
  /// hook calls [ChatDocumentSurfaceLink.refresh] so peer writes land in
  /// the live transcript (the AgentDocSurface.debugSurface pattern).
  static ChatDocumentSurfaceLink? debugSurface;

  @override
  State<ChatDocumentView> createState() => _ChatDocumentViewState();
}

/// Typed projection of the open chat's mesh participation: refresh hook
/// plus the status the transcript header shows (live peers, session
/// owner, this device's peer id).
final class ChatDocumentSurfaceLink {
  const ChatDocumentSurfaceLink({
    required this.refresh,
    required this.meshStatus,
  });

  final void Function() refresh;

  /// Live mesh snapshot: connected, presence count on this doc, the
  /// session owner's peer id (null = unclaimed), and THIS device's id.
  final ({bool live, int presenceCount, String? ownerPeerId, String? myPeerId})
  Function()
  meshStatus;
}

class _ChatDocumentViewState extends State<ChatDocumentView> {
  final _composerController = TextEditingController();
  final List<hc.DocumentNode> _path = [];
  final Map<int, TextEditingController> _messageControllers = {};
  bool _isSyncingControllers = false;
  StreamSubscription<dynamic>? _streamSubscription;
  StreamSubscription<AcpPendingPermission>? _permissionSubscription;
  bool _isSending = false;
  bool _turnFailed = false;
  final StringBuffer _turnBuffer = StringBuffer();
  List<AcpAgentInstallation> _installations = [];
  final Map<String, AcpPendingPermission> _pendingPermissions = {};
  ChatTransport? _selected;
  List<ChatTransport> _transports = const [];

  hc.DocumentNode get _current => _path.last;

  hc.ChatDocumentService get _chatService =>
      context.read<hc.ChatDocumentService>();
  AcpAgentRuntimeRegistry get _runtimeRegistry =>
      context.read<AcpAgentRuntimeRegistry>();
  AcpInstallationService get _installationService =>
      context.read<AcpInstallationService>();
  AgentConfigStore get _configStore => context.read<AgentConfigStore>();
  ChatInferenceResolver get _resolver => context.read<ChatInferenceResolver>();

  /// The runtime owning this document's ACP agent (created eagerly so the
  /// permission stream can be observed before the first turn starts).
  AcpAgentRuntime get _runtime => _runtimeRegistry.forDoc(widget.doc.id.value);

  bool get _acpSupported => PlatformInfo.isNativeDesktop;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
    _permissionSubscription = _runtime.permissionRequests.listen(
      _onPermissionRequest,
    );
    // Multiplayer-chat link: the shell's sync-cycle hook refreshes the
    // OPEN chat (peer writes arrive with each LAN mesh cycle), and the
    // doc joins its presence channel (ADR 0031 §1 — join is the caller's
    // job; a live replica only, never a setup side effect).
    ChatDocumentView.debugSurface = _surfaceLink;
    unawaited(AgentDocSurface.meshWiring?.joinDoc(widget.doc.id.value));
  }

  ChatDocumentSurfaceLink get _surfaceLink => ChatDocumentSurfaceLink(
    refresh: refreshAfterMeshSync,
    meshStatus: () {
      final wiring = AgentDocSurface.meshWiring;
      final status = wiring?.statusFor(widget.doc.id.value);
      return (
        live: wiring != null && (status?.connected ?? false),
        presenceCount: status?.presenceCount ?? 0,
        ownerPeerId: _current.blocks.firstOrNull?.ownerPeerId,
        myPeerId: wiring?.selfPeerId?.call(),
      );
    },
  );

  /// Sync-cycle hook (wired from the shell): re-read the fold, then —
  /// when THIS device owns the chat's agent session — claim peer turn
  /// requests from the mesh task board.
  void refreshAfterMeshSync() {
    if (!mounted) return;
    unawaited(_reloadCurrent().then((_) => _autoRunPeerTurnTasks()));
  }

  static const String _turnTaskPrefix = 'chat-turn';
  final Set<String> _handledRemoteTurns = {};

  /// Owner side of the peer-turn hop: pending `chat-turn` requests for
  /// THIS doc run here exactly once each (the peer composed the user
  /// block; it is already in the shared transcript).
  Future<void> _autoRunPeerTurnTasks() async {
    final wiring = AgentDocSurface.meshWiring;
    final board = wiring?.taskBoard?.call();
    final myPeerId = wiring?.selfPeerId?.call();
    if (board == null || myPeerId == null || _isSending) return;
    final owner = _current.blocks.firstOrNull?.ownerPeerId;
    if (owner != null && owner != myPeerId) return;
    final pending = board.pendingRequestsFor(
      widget.doc.id.value,
      selfPeerId: myPeerId,
    );
    for (final record in pending) {
      if (_handledRemoteTurns.contains(record.taskId)) continue;
      final marker = record.task.startsWith('$_turnTaskPrefix ')
          ? record.task.substring(_turnTaskPrefix.length + 1)
          : null;
      if (marker == null) continue;
      final userBlock = _current.blocks
          .where((block) => block.id.value == marker)
          .firstOrNull;
      if (userBlock == null || userBlock.content.trim().isEmpty) continue;
      _handledRemoteTurns.add(record.taskId);
      try {
        board.markRunning(record.taskId);
      } on Object {
        continue; // board write failed — leave it for the next cycle.
      }
      unawaited(
        _runLocalTurn(userBlock.content, appendUserBlock: false).then((_) {
          try {
            board.completeTask(record.taskId);
          } on Object {
            // Terminal write failed — the request stays visible.
          }
        }),
      );
      return; // one turn per cycle — the next claim follows completion.
    }
  }

  Future<void> _initialize() async {
    final repository = context.read<hc.DocumentRepository>();
    final result = await repository.get(hc.NodeId(widget.doc.id.value));
    final node = switch (result) {
      final hc.DocFound found => found.node,
      _ => hc.DocumentNode(
        id: hc.NodeId(widget.doc.id.value),
        formatId: DocFormatIds.chat,
        blocks: [
          hc.Block(
            id: _nextNodeId(),
            type: hc.BlockType.heading,
            content: widget.doc.title,
            level: 1,
          ),
        ],
        createdAt: widget.doc.createdAt,
        updatedAt: widget.doc.updatedAt,
      ),
    };
    if (!mounted) return;
    setState(() => _path.add(node));
    if (_path.length == 1) await _persistRoot(_current);
    await _detectAgents();
    _rebuildTransports();
    _restoreSelectedTransport();
  }

  Future<void> _detectAgents() async {
    // ACP agents are local CLI processes discovered via `which` — desktop
    // only. On mobile/web there is nothing to detect, and spawning `which`
    // on Android either hangs the detection chain or litters the system
    // with useless process forks. Hosted chat works everywhere; the
    // desktop gate now scopes to ACP only.
    if (!_acpSupported) return;
    try {
      final installations = await _installationService.detectAll();
      if (!mounted) return;
      setState(() => _installations = installations);
    } on Exception {
      if (!mounted) return;
      setState(() => _installations = []);
    }
  }

  /// Builds the picker contents: hosted models from the agent config first
  /// (they work on every platform), then ACP agents (desktop only).
  void _rebuildTransports() {
    final transports = <ChatTransport>[];
    for (final entry in _configStore.config.providers.entries) {
      for (final model in entry.value.models) {
        transports.add(
          HostedChatTransport(providerId: entry.key, model: model),
        );
      }
    }
    for (final installation in _installations) {
      transports.add(
        AcpChatTransport(
          agentKey: installation.entry.id,
          label: installation.entry.displayName,
          installation: installation,
        ),
      );
    }
    if (_acpSupported) {
      final environment = _configStore.environment;
      for (final entry in _configStore.config.agentServers.entries) {
        final expanded = <String, String>{
          for (final envEntry in entry.value.env.entries)
            envEntry.key: _configStore
                .expandEnv(envEntry.value, environment: environment)
                .value,
        };
        transports.add(
          AcpChatTransport(
            agentKey: 'config:${entry.key}',
            label: entry.value.displayName ?? entry.key,
            config: AcpRuntimeConfig(
              command: entry.value.command,
              arguments: entry.value.args,
              environment: expanded.isEmpty ? null : expanded,
            ),
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() => _transports = transports);
  }

  /// Selection precedence: the doc's persisted ACP agent, then its
  /// persisted (provider, model), then the config chat defaults, then the
  /// first detected ACP agent.
  void _restoreSelectedTransport() {
    if (_selected != null && _transports.contains(_selected)) return;
    final title = _current.blocks.firstOrNull;
    ChatTransport? selected;
    final agentKey = title?.agentKey;
    if (agentKey != null) {
      selected = _transports.whereType<AcpChatTransport>().firstWhereOrNull(
        (transport) => transport.agentKey == agentKey,
      );
    }
    if (selected == null) {
      final provider = title?.provider;
      final model = title?.model;
      if (provider != null && model != null) {
        selected = _transports
            .whereType<HostedChatTransport>()
            .firstWhereOrNull(
              (transport) =>
                  transport.providerId == provider && transport.model == model,
            );
      }
    }
    selected ??= () {
      final target = _resolver.defaultTarget();
      if (target == null) return null;
      return _transports.whereType<HostedChatTransport>().firstWhereOrNull(
        (transport) =>
            transport.providerId == target.providerId &&
            transport.model == target.model,
      );
    }();
    selected ??= _transports.whereType<AcpChatTransport>().firstOrNull;
    if (!mounted) return;
    setState(() => _selected = selected);
  }

  Future<void> _selectTransport(final ChatTransport transport) async {
    setState(() => _selected = transport);
    // Persist the pick on the doc, replacing the OTHER family's record so
    // reopening the doc restores exactly what this conversation used.
    switch (transport) {
      case final HostedChatTransport hosted:
        await _chatService.updateChatMetadata(
          _current.id,
          provider: hosted.providerId,
          model: hosted.model,
          clearAgentKey: true,
        );
      case final AcpChatTransport acp:
        await _chatService.updateChatMetadata(
          _current.id,
          agentKey: acp.agentKey,
          clearProvider: true,
          clearModel: true,
        );
    }
    await _reloadCurrent();
  }

  Future<void> _persistRoot(hc.DocumentNode node) async {
    final repository = context.read<hc.DocumentRepository>();
    await repository.save(node);
    final stub = ProjectModelDoc(
      id: ProjectModelId(node.id.value),
      createdAt: node.createdAt,
      updatedAt: node.updatedAt,
      formatId: DocFormatIds.chat,
      title: node.blocks.firstOrNull?.content ?? '',
    );
    if (mounted) context.read<OpenedProjectNotifier>().updateProject(stub);
  }

  Future<void> _replaceBlocks(List<hc.Block> blocks) async {
    final updated = _current.withBlocks(blocks);
    setState(() => _path[_path.length - 1] = updated);
    await _chatService.repository.save(updated);
    if (_path.length == 1) {
      await _persistRoot(updated);
    } else {
      final parentIndex = _path.length - 2;
      await _chatService.repository.save(_path[parentIndex]);
    }
  }

  // ------------------------------------------------------------------
  // sending
  // ------------------------------------------------------------------

  /// Multiplayer turn routing (ADR 0012: transport membership never
  /// grants execution authority). When the LAN mesh is live and another
  /// peer owns this chat's agent session, THIS device composes into the
  /// shared doc and routes the TURN to the owner over the mesh task
  /// board — it never runs a second agent against the same conversation.
  ({bool routeToOwner, String? myPeerId, String? ownerPeerId}) _turnRouting() {
    final wiring = AgentDocSurface.meshWiring;
    final myPeerId = wiring?.selfPeerId?.call();
    if (wiring == null || myPeerId == null) {
      return (routeToOwner: false, myPeerId: null, ownerPeerId: null);
    }
    final owner = _current.blocks.firstOrNull?.ownerPeerId;
    if (owner == null || owner == myPeerId) {
      return (routeToOwner: false, myPeerId: myPeerId, ownerPeerId: owner);
    }
    return (routeToOwner: true, myPeerId: myPeerId, ownerPeerId: owner);
  }

  Future<void> _send() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _isSending || !mounted) return;
    _composerController.clear();
    await _startTurn(text);
  }

  Future<void> _startTurn(
    final String text, {
    final hc.NodeId? reuseAssistantBlockId,
  }) async {
    if (_isSending || !mounted) return;
    final routing = _turnRouting();
    if (reuseAssistantBlockId == null && routing.routeToOwner) {
      // Peer compose: the message lands in the shared doc; the turn
      // request rides the task board to the owner device. The reply is
      // the OWNER's write — it converges back over the mesh.
      final userBlockId = _nextNodeId();
      await _chatService.appendMessage(
        _current.id,
        role: hc.ChatRole.user,
        content: text,
        blockId: userBlockId,
      );
      final board = AgentDocSurface.meshWiring?.taskBoard?.call();
      if (board == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('mesh task board is not live')),
        );
        return;
      }
      board.requestTask(
        docId: widget.doc.id.value,
        task: '$_turnTaskPrefix ${userBlockId.value}',
        originPeerId: routing.myPeerId ?? '',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'queued for the session owner (${routing.ownerPeerId})',
          ),
        ),
      );
      await _reloadCurrent();
      return;
    }
    await _runLocalTurn(text, reuseAssistantBlockId: reuseAssistantBlockId);
    // Ownership claim: the first device to actually run a turn takes the
    // session (the title block carries it; peers route to it from then
    // on). Written through the same LWW doc ops, so it converges.
    if (reuseAssistantBlockId == null && routing.myPeerId != null) {
      final owner = _current.blocks.firstOrNull?.ownerPeerId;
      if (owner == null) {
        try {
          await _chatService.updateChatMetadata(
            _current.id,
            ownerPeerId: routing.myPeerId,
          );
        } on StateError {
          // Doc path changed mid-claim; the next turn claims instead.
        }
      }
    }
  }

  Future<void> _runLocalTurn(
    final String text, {
    final hc.NodeId? reuseAssistantBlockId,
    final bool appendUserBlock = true,
  }) async {
    if (_isSending || !mounted) return;
    // L10n strings are captured before any await: after an async gap the
    // context must not be touched (and the widget may be gone).
    final noTransportMessage = context.l10n.agentChatNoTransport;
    setState(() => _isSending = true);
    _turnBuffer.clear();
    _turnFailed = false;
    try {
      final assistantBlockId = reuseAssistantBlockId ?? _nextNodeId();
      if (reuseAssistantBlockId == null && appendUserBlock) {
        await _chatService.appendMessage(
          _current.id,
          role: hc.ChatRole.user,
          content: text,
          blockId: _nextNodeId(),
        );
        await _reloadCurrent();
      }
      await _chatService.appendMessage(
        _current.id,
        role: hc.ChatRole.assistant,
        content: '',
        blockId: assistantBlockId,
        status: hc.MessageStatus.streaming,
      );
      await _reloadCurrent();
      final transport = _selected;
      final stream = switch (transport) {
        final AcpChatTransport acp => await _acpStream(acp, text),
        final HostedChatTransport hosted => await _hostedStream(hosted),
        null => throw StateError(noTransportMessage),
      };
      _streamSubscription = stream.listen(
        (update) => _onTurnUpdate(update, assistantBlockId),
        // A stream that errored still emits done afterwards — the flag
        // keeps the failure durable (never overwritten with complete).
        onDone: () {
          if (_turnFailed) return;
          unawaited(_finishTurn(assistantBlockId));
        },
        onError: (final Object error) {
          _turnFailed = true;
          unawaited(_failTurn(assistantBlockId, error));
        },
      );
    } on Object catch (error) {
      // `on Exception` would let StateError (an Error) escape — e.g. the
      // "No ACP agent detected" throw from session setup — and surface as
      // an unhandled zone error instead of a visible message.
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  /// The ACP working directory for this chat: the user-picked workspace
  /// persisted on the title block, else the user's home. `Directory.current`
  /// of a GUI-launched app is meaningless (`/` on macOS Finder) — never an
  /// honest anchor for a coding agent's file tools.
  String get _acpWorkspace =>
      _current.blocks.firstOrNull?.workspace ??
      Platform.environment['HOME'] ??
      Directory.current.path;

  Future<Stream<TurnUpdate>> _acpStream(
    final AcpChatTransport transport,
    final String text,
  ) async {
    if (!_acpSupported) {
      throw StateError(context.l10n.agentChatAcpDesktopOnly);
    }
    final authRequiredMessage = context.l10n.agentChatAuthRequired;
    final workspace = _acpWorkspace;
    final config =
        transport.config ??
        AcpRuntimeConfig.fromInstallation(
          transport.installation ??
              (throw StateError(context.l10n.agentChatNoAgentDetected)),
          workingDirectory: workspace,
        );
    final runtime = await _runtimeRegistry.ensureStarted(
      widget.doc.id.value,
      transport.agentKey,
      config,
    );
    // Session continuity: the persisted sessionId is RESUMED while the
    // process still owns it, so consecutive messages continue one agent
    // conversation. Only a dead session (process restarted, agent
    // switched) falls back to session/new — and says so in the transcript.
    final title = _current.blocks.first;
    final persisted = title.sessionId;
    final hadPriorTurns = _current.blocks.any(
      (block) =>
          block.type == hc.BlockType.message &&
          block.role == hc.ChatRole.assistant,
    );
    var resumed = false;
    if (persisted != null && runtime.sessions.containsKey(persisted)) {
      runtime.switchTo(persisted);
      resumed = true;
    } else if (persisted != null) {
      // The session id lives on the SHARED doc: this process doesn't know
      // it (restart, or this device just took ownership). Try to reload
      // the conversation in the agent itself; agents without session/load
      // answer -32601 and the honest context-reset row follows.
      try {
        await runtime.resume(persisted, workingDirectory: workspace);
        resumed = true;
      } on AcpAuthRequiredException catch (error) {
        // Zed-parity auth: the agent owns its credentials. Surface a
        // durable row naming the fix (terminal-auth agents) and, when the
        // agent advertises ACP methods, offer the in-protocol sign-in.
        await _appendAuthRow(transport, error);
        throw StateError(authRequiredMessage);
      } on AcpRemoteError {
        await runtime.newSession(workspace);
      }
    } else {
      await runtime.newSession(workspace);
    }
    if (!resumed && persisted != null && hadPriorTurns) {
      await _chatService.appendMessage(
        _current.id,
        role: hc.ChatRole.assistant,
        content: context.l10n.agentChatContextReset,
        blockId: _nextNodeId(),
      );
      await _reloadCurrent();
    }
    final currentTitle = _current.blocks.first;
    final titleChanged =
        currentTitle.agentKey != transport.agentKey ||
        currentTitle.workspace != workspace ||
        currentTitle.sessionId != runtime.currentSessionId;
    if (titleChanged) {
      await _replaceBlocks([
        currentTitle.copyWith(
          agentKey: transport.agentKey,
          workspace: workspace,
          sessionId: runtime.currentSessionId,
        ),
        ..._current.blocks.skip(1),
      ]);
    }
    return runtime
        .send(text)
        .map(
          (update) => TurnUpdate(
            textDelta: update.textDelta,
            toolTitle: update.textDelta == null ? update.message : null,
            toolStatus: update.toolStatus,
            planLines: update.planEntries,
          ),
        );
  }

  /// Appends the durable AUTH row: the agent's catalog hint (the exact
  /// command the user runs in their terminal) plus, when the agent
  /// advertises ACP auth methods, an in-protocol sign-in button.
  Future<void> _appendAuthRow(
    final AcpChatTransport transport,
    final AcpAuthRequiredException error,
  ) async {
    final hint = AcpAgentCatalog.defaultEntries
        .where((entry) => entry.id == transport.agentKey)
        .firstOrNull
        ?.authHint;
    await _chatService.appendMessage(
      _current.id,
      role: hc.ChatRole.assistant,
      content: hint ?? error.message,
      blockId: _nextNodeId(),
      title: 'AUTH',
    );
    await _reloadCurrent();
    final method = error.authMethods.firstOrNull;
    if (method != null && mounted) {
      final runtime = _runtimeRegistry.maybe(widget.doc.id.value);
      if (runtime != null) {
        unawaited(
          runtime
              .authenticate(method.methodId)
              .then((_) async {
                await _safeReplaceMessage(
                  _current.blocks.last.id,
                  'AUTH → signed in via ${method.name ?? method.methodId}',
                );
                if (mounted) unawaited(_reloadCurrent());
              })
              .catchError((final Object _) {}),
        );
      }
    }
  }

  Future<Stream<TurnUpdate>> _hostedStream(
    final HostedChatTransport transport,
  ) async {
    final missingKeyMessage = context.l10n.agentChatMissingKey;
    final consentDeclinedMessage = context.l10n.agentChatConsentDeclined;
    final resolution = await _resolver.resolve(
      documentId: widget.doc.id.value,
      providerId: transport.providerId,
      model: transport.model,
    );
    switch (resolution.readiness) {
      case HostedChatReadiness.missingCredential:
        throw StateError(missingKeyMessage);
      case HostedChatReadiness.consentRequired:
        final granted = await _askConsent(transport);
        if (!granted) {
          throw StateError(consentDeclinedMessage);
        }
        final retry = await _resolver.resolve(
          documentId: widget.doc.id.value,
          providerId: transport.providerId,
          model: transport.model,
        );
        if (retry.port == null) {
          throw StateError(consentDeclinedMessage);
        }
        return _runHosted(retry.port!, transport);
      case HostedChatReadiness.ready:
        return _runHosted(resolution.port!, transport);
    }
  }

  Stream<TurnUpdate> _runHosted(
    final DocInferencePort port,
    final HostedChatTransport transport,
  ) async* {
    final title = _current.blocks.firstOrNull;
    final systemPrompt =
        title?.systemPrompt ?? _configStore.config.chat.systemPrompt;
    final messages = <ChatMessage>[
      if (systemPrompt.isNotEmpty)
        ChatMessage(role: 'system', content: systemPrompt),
      for (final block in _current.blocks)
        if (block.type == hc.BlockType.message &&
            block.toolCallId == null &&
            block.status == hc.MessageStatus.complete &&
            block.content.trim().isNotEmpty)
          ChatMessage(role: block.role!.name, content: block.content),
    ];
    await _chatService.updateChatMetadata(
      _current.id,
      provider: transport.providerId,
      model: transport.model,
    );
    await _reloadCurrent();
    await for (final delta in port.chat(messages)) {
      yield TurnUpdate(textDelta: delta);
    }
  }

  Future<bool> _askConsent(final HostedChatTransport transport) async {
    final granted = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(context.l10n.agentChatConsentTitle),
        content: Text(
          context.l10n.agentChatConsentBody(
            transport.providerId,
            transport.model,
          ),
        ),
        actions: [
          TextButton(
            key: const Key('chat.consent.deny'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.deny),
          ),
          TextButton(
            key: const Key('chat.consent.allow'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.allow),
          ),
        ],
      ),
    );
    if (granted ?? false) {
      await _resolver.grantConsent(
        documentId: widget.doc.id.value,
        providerId: transport.providerId,
        model: transport.model,
      );
    }
    return granted ?? false;
  }

  /// Latest tool-call state per title, in first-seen order (DESIGN §6:
  /// render what the host observed). Re-assignments UPDATE the row instead
  /// of stacking pending → in_progress → completed lines.
  final Map<String, String> _toolBeats = {};
  List<String>? _planLines;

  void _onTurnUpdate(final TurnUpdate update, final hc.NodeId blockId) {
    if (update.textDelta != null) {
      _turnBuffer.write(update.textDelta);
    }
    if (update.toolTitle != null) {
      _toolBeats[update.toolTitle!] = update.toolStatus ?? '';
    }
    if (update.planLines != null) {
      _planLines = update.planLines;
    }
    unawaited(_safeReplaceMessage(blockId, _turnSnapshot()));
  }

  /// The streamed assistant row: free text plus one line per observed tool
  /// beat and the latest plan, split back into durable blocks at turn end.
  String _turnSnapshot() {
    final buffer = StringBuffer(_turnBuffer);
    for (final entry in _toolBeats.entries) {
      buffer
        ..writeln()
        ..write(
          entry.value.isEmpty
              ? '[tool] ${entry.key}'
              : '[tool] ${entry.key} · ${entry.value}',
        );
    }
    final plan = _planLines;
    if (plan != null && plan.isNotEmpty) {
      buffer
        ..writeln()
        ..write('[plan] ${plan.join(' | ')}');
    }
    return buffer.toString();
  }

  String? _contentOf(final hc.NodeId blockId) {
    for (final block in _current.blocks) {
      if (block.id == blockId) return block.content;
    }
    return null;
  }

  Future<void> _finishTurn(final hc.NodeId blockId) async {
    // Split accumulated [tool]/[plan] lines out of the assistant text into
    // their own durable beat blocks (DESIGN §6: render what the host
    // observed).
    final snapshot = _turnSnapshot();
    final content = snapshot.trim().isNotEmpty
        ? snapshot
        : _contentOf(blockId) ?? '';
    final toolBeats = <String, String>{};
    String? planLine;
    final textLines = <String>[];
    for (final line in content.split('\n')) {
      if (line.startsWith('[tool] ')) {
        final body = line.substring('[tool] '.length).trim();
        final separator = body.lastIndexOf(' · ');
        final title = separator < 0 ? body : body.substring(0, separator);
        final status = separator < 0 ? '' : body.substring(separator + 3);
        if (title.isNotEmpty) toolBeats[title] = status;
        continue;
      }
      if (line.startsWith('[plan] ')) {
        planLine = line.substring('[plan] '.length).trim();
        continue;
      }
      textLines.add(line);
    }
    await _safeReplaceMessage(blockId, textLines.join('\n').trimRight());
    await _chatService.updateMessageStatus(
      _current.id,
      blockId,
      status: hc.MessageStatus.complete,
    );
    for (final entry in toolBeats.entries) {
      try {
        await _chatService.appendMessage(
          _current.id,
          role: hc.ChatRole.assistant,
          content: entry.value,
          blockId: _nextNodeId(),
          toolCallId: entry.key,
          title: entry.key,
        );
      } on StateError {
        break;
      }
    }
    if (planLine != null && planLine.isNotEmpty) {
      try {
        await _chatService.appendMessage(
          _current.id,
          role: hc.ChatRole.assistant,
          content: planLine,
          blockId: _nextNodeId(),
          toolCallId: 'plan',
          title: 'plan',
        );
      } on StateError {
        // The doc path changed mid-turn; the plan line stays in the text.
      }
    }
    _toolBeats.clear();
    _planLines = null;
    _streamSubscription = null;
    if (mounted) {
      setState(() => _isSending = false);
      unawaited(_reloadCurrent());
    }
  }

  Future<void> _failTurn(final hc.NodeId blockId, final Object error) async {
    await _chatService.updateMessageStatus(
      _current.id,
      blockId,
      status: hc.MessageStatus.failed,
    );
    _streamSubscription = null;
    if (mounted) {
      setState(() => _isSending = false);
      unawaited(_reloadCurrent());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  /// Re-runs the turn for a failed assistant block against the same
  /// preceding user message, reusing the block (no duplicate history).
  Future<void> _retryAssistant(final hc.Block failedBlock) async {
    final blocks = _current.blocks;
    final index = blocks.indexWhere((block) => block.id == failedBlock.id);
    String? userText;
    for (var i = index - 1; i >= 0; i--) {
      final block = blocks[i];
      if (block.type == hc.BlockType.message &&
          block.role == hc.ChatRole.user) {
        userText = block.content;
        break;
      }
    }
    if (userText == null || userText.trim().isEmpty) return;
    await _safeReplaceMessage(failedBlock.id, '');
    await _startTurn(userText, reuseAssistantBlockId: failedBlock.id);
  }

  Future<void> _safeReplaceMessage(hc.NodeId blockId, String content) async {
    try {
      await _chatService.replaceMessage(_current.id, blockId, content: content);
    } on Object {
      // The current path changed before a late stream event arrived (or the
      // doc was closed mid-stream); never let a late stream event crash the
      // view.
    }
  }

  Future<void> _reloadCurrent() async {
    final result = await _chatService.repository.get(_current.id);
    if (!mounted) return;
    if (result case final hc.DocFound found) {
      setState(() => _path[_path.length - 1] = found.node);
    }
  }

  Future<void> _climbUp() async {
    if (_path.length <= 1) return;
    setState(_path.removeLast);
    await _reloadCurrent();
  }

  void _stop() {
    if (_selected is AcpChatTransport) _runtime.cancel();
    unawaited(_streamSubscription?.cancel());
    _streamSubscription = null;
    if (mounted) setState(() => _isSending = false);
  }

  Widget _policyToggle(final ChatPermissionPolicy policy) {
    final active = policy == _permissionPolicy;
    return GestureDetector(
      key: Key('chat.perm.mode.${policy.name}'),
      behavior: HitTestBehavior.opaque,
      onTap: _isSending ? null : () => unawaited(_setPermissionPolicy(policy)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Text(
          policy.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 0.8,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
            decoration: active ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // ACP permission round-trip
  // ------------------------------------------------------------------

  Future<void> _onPermissionRequest(final AcpPendingPermission pending) async {
    if (!mounted) return;
    // The stance decides FIRST (codex/zed/cursor logic): full access
    // answers everything, workspace edits answers the working set
    // (read/edit/move) — only `ask` waits for the user's buttons. The
    // durable row records WHICH layer answered, never a silent allow.
    final policy = _permissionPolicy;
    if (policy.autoAllows(pending.request)) {
      unawaited(pending.allow());
      try {
        await _chatService.appendMessage(
          _current.id,
          role: hc.ChatRole.assistant,
          content: 'PERM → auto-allowed (${policy.label.toLowerCase()})',
          blockId: _nextNodeId(),
          toolCallId: pending.request.toolCallId,
          title: pending.request.title,
        );
      } on StateError {
        return;
      }
      await _reloadCurrent();
      return;
    }
    final blockId = _nextNodeId();
    _pendingPermissions[pending.request.toolCallId] = pending;
    try {
      await _chatService.appendMessage(
        _current.id,
        role: hc.ChatRole.assistant,
        content: pending.request.details ?? '',
        blockId: blockId,
        toolCallId: pending.request.toolCallId,
        title: pending.request.title,
        status: hc.MessageStatus.streaming,
      );
    } on StateError {
      return;
    }
    await _reloadCurrent();
  }

  Future<void> _answerPermission(
    final AcpPendingPermission pending,
    final bool allow,
  ) async {
    if (allow) {
      await pending.allow();
    } else {
      await pending.reject();
    }
    _pendingPermissions.remove(pending.request.toolCallId);
    final blocks = _current.blocks;
    var index = -1;
    for (var i = blocks.length - 1; i >= 0; i--) {
      if (blocks[i].toolCallId == pending.request.toolCallId) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      await _safeReplaceMessage(
        blocks[index].id,
        'PERM → ${allow ? 'allowed' : 'rejected'}',
      );
      await _chatService.updateMessageStatus(
        _current.id,
        blocks[index].id,
        status: hc.MessageStatus.complete,
      );
    }
    if (mounted) unawaited(_reloadCurrent());
  }

  Future<void> _editSystemPrompt() async {
    final title = _current.blocks.firstOrNull;
    final controller = TextEditingController(text: title?.systemPrompt ?? '');
    await showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(context.l10n.agentChatSystemPromptTitle),
        content: TextField(
          key: const Key('chat.system.prompt.field'),
          controller: controller,
          maxLines: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            key: const Key('chat.system.prompt.save'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
    if (!mounted) return;
    await _chatService.updateChatMetadata(
      _current.id,
      systemPrompt: controller.text.trim(),
      clearSystemPrompt: controller.text.trim().isEmpty,
    );
    await _reloadCurrent();
  }

  @override
  void dispose() {
    if (identical(ChatDocumentView.debugSurface, _surfaceLink)) {
      ChatDocumentView.debugSurface = null;
    }
    unawaited(AgentDocSurface.meshWiring?.leaveDoc(widget.doc.id.value));
    unawaited(_streamSubscription?.cancel());
    unawaited(_permissionSubscription?.cancel());
    for (final controller in _messageControllers.values) {
      controller.dispose();
    }
    _composerController.dispose();
    super.dispose();
  }

  String get _statusLabel {
    final transport = _selected;
    if (transport is HostedChatTransport) {
      return context.l10n.agentChatCloudLabel(transport.label);
    }
    if (transport is AcpChatTransport) {
      final status = _runtime.status;
      if (!_acpSupported) return 'ACP · ${context.l10n.desktopOnly}';
      return 'ACP ${switch (status) {
        AcpRuntimeStatus.ready => context.l10n.agentChatStatusReady,
        AcpRuntimeStatus.starting => context.l10n.agentChatStatusStarting,
        AcpRuntimeStatus.error => context.l10n.agentChatStatusError,
        AcpRuntimeStatus.stopped => context.l10n.agentChatStatusStopped,
        AcpRuntimeStatus.idle => context.l10n.agentChatStatusIdle,
      }}';
    }
    return context.l10n.agentChatNoTransport;
  }

  /// The chat's permission stance (title block; ask = deny-by-default).
  ChatPermissionPolicy get _permissionPolicy => ChatPermissionPolicy.fromName(
    _current.blocks.firstOrNull?.permissionMode,
  );

  Future<void> _setPermissionPolicy(final ChatPermissionPolicy policy) async {
    if (policy == _permissionPolicy) return;
    await _chatService.updateChatMetadata(
      _current.id,
      permissionMode: policy.name,
    );
    await _reloadCurrent();
    // Best-effort agent side: when the agent advertises its own modes
    // (claude-code's default/acceptEdits/bypassPermissions...), drive the
    // matching one. The client-side policy stays the enforcement layer.
    final sessionId = _runtime.currentSessionId;
    final modes = sessionId == null ? null : _runtime.sessionModesOf(sessionId);
    final agentModeId = modes == null
        ? null
        : policy.preferredAgentModeId(modes);
    if (sessionId != null && agentModeId != null) {
      try {
        await _runtime.setMode(sessionId, agentModeId);
      } on Object {
        // The agent refused or lacks session/set_mode — the client-side
        // policy already applies, nothing to surface.
      }
    }
  }

  /// Multiplayer status: live LAN peers on this doc + who owns the
  /// agent session. Quiet when the mesh is not set up (single-device
  /// chat looks exactly like before).
  String get _meshLabel {
    final status = ChatDocumentView.debugSurface?.meshStatus();
    if (status == null || !status.live) return '';
    final mine = status.myPeerId;
    final owner = status.ownerPeerId;
    final ownerLabel = owner == null
        ? 'unclaimed'
        : owner == mine
        ? 'owned here'
        : 'owned by ${owner.substring(0, owner.length.clamp(0, 6))}…';
    return 'mesh · ${status.presenceCount} here · $ownerLabel';
  }

  @override
  Widget build(BuildContext context) {
    if (_path.isEmpty) return const Center(child: CircularProgressIndicator());
    final messages = [
      for (final block in _current.blocks)
        if (block.type == hc.BlockType.message) block,
    ];
    return PopScope(
      canPop: _path.length == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_climbUp());
      },
      child: Column(
        children: [
          if (_path.length > 1)
            Row(
              children: [
                IconButton(
                  onPressed: _climbUp,
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    _current.spanSnapshot ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.greenAccent),
                const Gap(6),
                Text(_statusLabel),
                const Gap(10),
                Flexible(child: Text(_meshLabel)),
                const Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Gap(8),
                        for (final policy in ChatPermissionPolicy.values)
                          _policyToggle(policy),
                      ],
                    ),
                  ),
                ),
                if (_selected is HostedChatTransport)
                  IconButton(
                    key: const Key('chat.system.edit'),
                    tooltip: context.l10n.agentChatSystemPromptTitle,
                    onPressed: _editSystemPrompt,
                    icon: const Icon(Icons.subject, size: 20),
                  ),
                Flexible(
                  child: DropdownButton<ChatTransport>(
                    key: const Key('chat.transport.picker'),
                    value: _transports.contains(_selected) ? _selected : null,
                    hint: Text(context.l10n.agentChatPickTransport),
                    isExpanded: true,
                    items: [
                      for (final transport in _transports)
                        DropdownMenuItem(
                          value: transport,
                          child: Text(transport.label),
                        ),
                    ],
                    onChanged: _isSending
                        ? null
                        : (v) {
                            if (v != null) unawaited(_selectTransport(v));
                          },
                  ),
                ),
                if (_selected is AcpChatTransport)
                  IconButton(
                    key: const Key('chat.workspace.pick'),
                    tooltip: context.l10n.agentChatWorkspaceTooltip,
                    onPressed: _isSending ? null : _pickWorkspace,
                    icon: const Icon(Icons.create_new_folder_outlined),
                  ),
                if (_acpSupported &&
                    _transports.whereType<AcpChatTransport>().isEmpty)
                  IconButton(
                    onPressed: _showInstallHelp,
                    icon: const Icon(Icons.download_outlined),
                  ),
                if (_acpSupported)
                  IconButton(
                    onPressed: _isSending ? null : _useLocalClient,
                    tooltip: context.l10n.agentChatUseLocalExecutable,
                    icon: const Icon(Icons.folder_open),
                  ),
                IconButton(
                  key: const Key('chat.settings.open'),
                  tooltip: context.l10n.agentSettingsTitle,
                  onPressed: () =>
                      unawaited(AgentConfigSettingsPane.show(context)),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message.role == hc.ChatRole.user;
                final pending = message.toolCallId == null
                    ? null
                    : _pendingPermissions[message.toolCallId];
                final controller = _messageControllers.putIfAbsent(index, () {
                  final value = TextEditingController(text: message.content);
                  value.addListener(() {
                    if (_isSyncingControllers) return;
                    final text = value.text;
                    if (text != message.content) {
                      unawaited(_replaceMessage(message.id, text));
                    }
                  });
                  return value;
                });
                if (controller.text != message.content) {
                  _isSyncingControllers = true;
                  controller.text = message.content;
                  _isSyncingControllers = false;
                }
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: const BoxConstraints(maxWidth: 560),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.toolCallId != null)
                          Text(
                            message.title ?? message.toolCallId!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(letterSpacing: 1.2),
                          ),
                        if (message.content.isNotEmpty)
                          TextField(
                            key: ValueKey(message.id.value),
                            controller: controller,
                            minLines: 1,
                            maxLines: null,
                            decoration: const InputDecoration.collapsed(
                              hintText: '',
                            ),
                          ),
                        Wrap(
                          children: [
                            if (pending != null) ..._permissionButtons(pending),
                            if (pending == null &&
                                message.status == hc.MessageStatus.failed)
                              TextButton.icon(
                                key: Key('chat.msg.${message.id.value}.retry'),
                                onPressed: _isSending
                                    ? null
                                    : () => unawaited(_retryAssistant(message)),
                                label: Text(context.l10n.retry),
                                icon: const Icon(Icons.refresh, size: 18),
                              ),
                            TextButton.icon(
                              onPressed: () =>
                                  unawaited(_discussMessage(message)),
                              label: Text(context.l10n.discuss),
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                unawaited(
                                  Clipboard.setData(
                                    ClipboardData(text: message.content),
                                  ),
                                );
                              },
                              label: Text(context.l10n.copy),
                              icon: const Icon(Icons.copy, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _composerController,
                    minLines: 1,
                    maxLines: 6,
                  ),
                ),
                if (_isSending)
                  IconButton.filledTonal(
                    onPressed: _stop,
                    icon: const Icon(Icons.stop),
                  )
                else
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reject-first permission buttons (DESIGN §4: deny-by-default is
  /// shown, never assumed). Deliberately enabled WHILE the turn is
  /// streaming: `session/request_permission` only arrives mid-turn, and
  /// the agent holds the turn until it is answered — disabling these here
  /// deadlocked every permission round-trip.
  List<Widget> _permissionButtons(final AcpPendingPermission pending) {
    final tid = pending.request.toolCallId;
    return [
      TextButton(
        key: Key('chat.perm.$tid.reject'),
        onPressed: () => unawaited(_answerPermission(pending, false)),
        child: Text(context.l10n.reject),
      ),
      TextButton(
        key: Key('chat.perm.$tid.allow'),
        onPressed: () => unawaited(_answerPermission(pending, true)),
        child: Text(context.l10n.allow),
      ),
    ];
  }

  Future<void> _replaceMessage(hc.NodeId blockId, String content) async {
    try {
      await _chatService.replaceMessage(_current.id, blockId, content: content);
    } on StateError {
      return;
    }
    await _safeReloadWithoutControllers();
  }

  Future<void> _safeReloadWithoutControllers() async {
    final result = await _chatService.repository.get(_current.id);
    if (!mounted) return;
    if (result case final hc.DocFound found) {
      setState(() => _path[_path.length - 1] = found.node);
    }
  }

  Future<void> _discussMessage(hc.Block message) async {
    final child = await _chatService.startAgentThread(
      parentNodeId: _current.id,
      anchorBlockId: message.id,
      title: message.content.isEmpty ? 'Discussion' : message.content,
    );
    if (!mounted) return;
    setState(() => _path.add(child));
  }

  /// Picks the ACP working directory for this chat (persisted on the title
  /// block; takes effect from the next session/new onward).
  Future<void> _pickWorkspace() async {
    final String? path;
    try {
      path = await getDirectoryPath();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }
    if (path == null || !mounted) return;
    await _chatService.updateChatMetadata(_current.id, workspace: path);
    await _reloadCurrent();
  }

  Future<void> _showInstallHelp() async {
    final commands = AcpAgentCatalog.defaultEntries
        .map((e) => e.installCommand ?? [])
        .where((c) => c.isNotEmpty)
        .map((c) => c.join(' '));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.agentChatInstallTitle),
        content: SelectableText(commands.join('\n')),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(context.l10n.close),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(_detectAgents());
            },
            child: Text(context.l10n.agentChatRecheck),
          ),
        ],
      ),
    );
  }

  Future<void> _useLocalClient() async {
    final XFile? file;
    try {
      file = await openFile(
        acceptedTypeGroups: [const XTypeGroup(label: 'Executables')],
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }
    if (file == null) return;
    final AcpAgentInstallation? installation;
    try {
      installation = await _installationService.detectLocalPath(file.path);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }
    if (!mounted) return;
    final picked = installation;
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.agentChatExecutableNotFound)),
      );
      return;
    }
    setState(() {
      _installations = [..._installations, picked];
      _transports = [
        ..._transports,
        AcpChatTransport(
          agentKey: picked.entry.id,
          label: picked.entry.displayName,
          installation: picked,
        ),
      ];
      _selected = _transports.last;
    });
  }
}

/// One streamed event of a chat turn — transport-agnostic (ACP agent or
/// hosted model).
final class TurnUpdate {
  const TurnUpdate({
    this.textDelta,
    this.toolTitle,
    this.toolStatus,
    this.planLines,
  });

  final String? textDelta;
  final String? toolTitle;
  final String? toolStatus;
  final List<String>? planLines;
}
