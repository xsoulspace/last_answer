import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/workbench/behaviour_connection.dart';
import 'package:lastanswer/workbench/workbench_harness_tools.dart';
import 'package:lastanswer/workbench/workbench_investigation.dart';
import 'package:lastanswer/workbench/workbench_scene.dart';
import 'package:lastanswer/workbench/workbench_strings.dart';
import 'package:provider/provider.dart';
import 'package:universal_automation_interface/universal_automation_interface.dart';
import 'package:uuid/uuid.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// One owner per authoritative repository; widgets and tools share it.
final _owners = Expando<hc.WorkbenchOwner>();
hc.WorkbenchOwner workbenchOwner(hc.DocumentRepository repository) =>
    _owners[repository] ??= hc.WorkbenchOwner(repository);

/// A projection endpoint, not a second content store or scheduler.
class WorkbenchScreen extends StatefulWidget {
  const WorkbenchScreen({
    this.project,
    this.viewerId,
    this.collaboration = false,
    super.key,
  });
  final bool collaboration;
  final String? project;

  /// Host-supplied stable projection address; absent gets a mount-local ID.
  final String? viewerId;
  static final _endpoints = <String, WorkbenchEndpoint>{};
  static Map<String, WorkbenchEndpoint> get endpoints =>
      Map.unmodifiable(_endpoints);

  /// Legacy implicit addressing remains valid for exactly one mounted view.
  static WorkbenchEndpoint? get endpoint => _endpoints.values.singleOrNull;
  @override
  State<WorkbenchScreen> createState() => _WorkbenchScreenState();
}

class WorkbenchEndpoint {
  WorkbenchEndpoint({required this.state, required this.act});
  final Map<String, Object?> Function() state;
  final Future<Map<String, Object?>> Function(
    String,
    Map<String, dynamic>,
    InteractionOrigin,
  )
  act;
}

class _WorkbenchScreenState extends State<WorkbenchScreen> {
  late hc.WorkbenchOwner owner;
  hc.DocumentNode? node;
  Map<String, dynamic> metadata = {};
  final controllers = <String, TextEditingController>{};
  final focusNodes = <String, FocusNode>{};
  final scroll = ScrollController();
  String? selected;
  String? focusedBlock;
  String? proposal;
  String? error;
  bool busy = false;
  Future<void> _uiTail = Future.value();
  bool inspect = false;
  bool away = false;
  hc.WorkProjection projection = hc.WorkProjection.document;
  hc.ReturnBehaviour? candidate;
  double? _dragWidth;
  InteractionSession? _interaction;
  final source = TextEditingController();
  final intent = TextEditingController();
  Map<String, dynamic>? bookmark;
  final replay = <Map<String, Object?>>[];
  int replayIndex = 0;
  SharedWorkbenchScope? sharedScope;
  String? harnessSession;
  String? harnessReceipt;
  late final String _viewerId;
  WorkbenchEndpoint? _endpoint;

  hc.ReturnBehaviour get behaviour => hc.ReturnBehaviour.fromJson(
    Map<String, dynamic>.from(metadata['behaviour'] as Map? ?? {}),
  );
  double get width => _dragWidth ?? behaviour.width;

  @override
  void initState() {
    super.initState();
    _viewerId = widget.viewerId ?? const Uuid().v4();
    if (_viewerId.trim().isEmpty) throw ArgumentError('invalid_viewer_id');
    SemanticsBinding.instance.addSemanticsActionListener(_onSemanticAction);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      owner = workbenchOwner(context.read<hc.DocumentRepository>());
      if (WorkbenchScreen._endpoints.containsKey(_viewerId)) {
        throw StateError('workbench_view_id_in_use');
      }
      _endpoint = WorkbenchEndpoint(state: _state, act: _act);
      WorkbenchScreen._endpoints[_viewerId] = _endpoint!;
      unawaited(
        _run(() async {
          if (widget.project != null) {
            await _open(widget.project!);
          }
        }),
      );
    });
  }

  @override
  void dispose() {
    if (identical(WorkbenchScreen._endpoints[_viewerId], _endpoint)) {
      WorkbenchScreen._endpoints.remove(_viewerId);
    }
    SemanticsBinding.instance.removeSemanticsActionListener(_onSemanticAction);
    for (final c in controllers.values) {
      c.dispose();
    }
    for (final f in focusNodes.values) {
      f.dispose();
    }
    source.dispose();
    intent.dispose();
    scroll.dispose();
    super.dispose();
  }

  // Accessibility input can update an occluded workbench while the platform
  // suspends normal vsync. Publish one frame after that input and after any
  // asynchronous operation settles; never keep an idle render loop running.
  void _onSemanticAction(ui.SemanticsActionEvent _) {
    scheduleMicrotask(_refreshBackgroundFrame);
  }

  void _refreshBackgroundFrame() {
    if (!mounted) return;
    final binding = WidgetsBinding.instance;
    if (binding.lifecycleState == AppLifecycleState.inactive ||
        binding.lifecycleState == AppLifecycleState.hidden ||
        binding.lifecycleState == AppLifecycleState.paused) {
      binding.scheduleWarmUpFrame();
    }
  }

  Map<String, Object?> _state() => {
    'viewerId': _viewerId,
    'project': node?.id.value,
    'selected': selected,
    'projection': projection.name,
    'inspecting': inspect,
    'away': away,
    'busy': busy,
    'error': error,
    'proposal': proposal,
    'behaviour': behaviour.toJson(),
    'candidate': candidate?.toJson(),
    'replay': replay,
    'replayIndex': replayIndex,
    'metadata': metadata,
    'blocks': node?.blocks.map((b) => b.toJson()).toList(),
    'harnessReceipt': harnessReceipt,
    'interaction': _interaction?.toJson(),
    'targets': node == null
        ? []
        : [
            {
              'id': 'project_open',
              'revision': hc.workRevision(node!),
              'kind': 'edge',
              'operations': ['insert_restore', 'remove_restore'],
            },
            {
              'id': 'writing_width',
              'revision': hc.workRevision(node!),
              'kind': 'boundary',
              'min': 320,
              'max': 1200,
            },
            for (final b in node!.blocks)
              {
                'id': b.id.value,
                'revision': hc.workRevision(node!),
                'kind': b.type.name,
              },
          ],
  };

  Future<void> _run(Future<void> Function() action) {
    final settled = Completer<void>();
    _uiTail = _uiTail.then((_) async {
      if (!mounted) {
        settled.complete();
        return;
      }
      setState(() {
        busy = true;
        error = null;
      });
      try {
        await action();
      } on Object catch (e) {
        if (mounted) setState(() => error = '$e');
      } finally {
        if (mounted) setState(() => busy = false);
        _refreshBackgroundFrame();
        settled.complete();
      }
    });
    return settled.future;
  }

  Future<void> _open(String id, {bool restorePosition = true}) async {
    final changingProject = node?.id.value != id;
    final next = await owner.read(id);
    if (next.kind == 'workbench_metadata') {
      throw const hc.WorkbenchRefusal('not_a_project');
    }
    node = next;
    if (changingProject) {
      selected = null;
      focusedBlock = null;
      proposal = null;
      candidate = null;
      away = false;
    }
    metadata = await owner.state(id);
    replay
      ..clear()
      ..addAll(
        (metadata['history'] as List? ?? [])
            .whereType<Map>()
            .where(
              (event) =>
                  event['kind'] == 'observed' ||
                  event['kind'] == 'fresh_execution',
            )
            .map(Map<String, Object?>.from),
      );
    replayIndex = replay.isEmpty ? 0 : replay.length - 1;
    for (final b in next.blocks) {
      final c = controllers.putIfAbsent(b.id.value, TextEditingController.new);
      if (c.text != b.content) c.text = b.content;
      focusNodes.putIfAbsent(b.id.value, FocusNode.new);
    }
    final savedView = widget.viewerId == null
        ? metadata['view']
        : (metadata['views'] as Map?)?[_viewerId];
    bookmark = _validatedBookmark(savedView);
    if (mounted && savedView != null && bookmark == null) {
      error = workbenchText(
        context,
        'Saved position could not be restored. Opened at the beginning.',
      );
    }
    if (mounted) setState(() {});
    if (restorePosition && savedView != null) await _restorePosition(behaviour);
  }

  Map<String, dynamic>? _validatedBookmark(Object? raw) {
    if (raw is! Map || raw.keys.any((key) => key is! String)) return null;
    final version = raw['version'] ?? 0; // Existing unversioned checkpoints.
    final offset = raw['offset'];
    final cursor = raw['cursor'];
    final extent = raw['extent'];
    if ((version != 0 && version != 1) ||
        offset is! num ||
        !offset.isFinite ||
        cursor is! int ||
        (version == 1 && cursor < 0) ||
        extent is! int ||
        (version == 1 && extent < 0) ||
        raw['revision'] is! String ||
        raw['inspect'] is! bool ||
        !hc.WorkProjection.values.any(
          (value) => value.name == raw['projection'],
        ) ||
        [
          'editor',
          'selected',
          'content',
        ].any((key) => raw[key] != null && raw[key] is! String)) {
      return null;
    }
    return Map<String, dynamic>.from(raw);
  }

  Future<void> _createSample() async {
    final now = DateTime.now().toUtc();
    final id = const Uuid().v4();
    await owner.repository.save(
      hc.DocumentNode(
        id: hc.NodeId(id),
        createdAt: now,
        updatedAt: now,
        formatId: 'article',
        blocks: [
          hc.Block(
            id: hc.NodeId('$id-title'),
            type: hc.BlockType.heading,
            content: 'A place to think and build',
            level: 1,
          ),
          hc.Block(
            id: hc.NodeId('$id-claim'),
            type: hc.BlockType.paragraph,
            content:
                'Keep the work close. Let the rest recede. A document is an editable projection of project work.',
          ),
          hc.Block(
            id: hc.NodeId('$id-next'),
            type: hc.BlockType.heading,
            content: 'Questions worth keeping',
            level: 1,
          ),
          hc.Block(
            id: hc.NodeId('$id-question'),
            type: hc.BlockType.paragraph,
            content:
                'How much context should remain visible? We can try a change without losing our place.',
          ),
        ],
      ),
    );
    await _open(id);
  }

  Future<void> _refresh() async {
    if (node != null) await _open(node!.id.value, restorePosition: false);
  }

  Future<void> _stage(
    String operation,
    Map<String, dynamic> arguments,
    InteractionOrigin origin,
  ) async {
    final n = node;
    if (n == null) throw const hc.WorkbenchRefusal('project_required');
    proposal = await owner.propose(
      project: n.id.value,
      actor: origin == InteractionOrigin.semanticAgent
          ? 'agent'
          : 'local_surface',
      origin: origin.name,
      intent: intent.text.isEmpty ? operation : intent.text,
      operation: operation,
      arguments: arguments,
      expectedRevision: hc.workRevision(n),
    );
    metadata = await owner.state(n.id.value);
    if (mounted) setState(() {});
  }

  Future<Map<String, Object?>> _act(
    String action,
    Map<String, dynamic> args,
    InteractionOrigin origin,
  ) async {
    if (busy) return {'ok': false, 'error': 'workbench_busy'};
    var ok = true;
    await _run(() async {
      try {
        if (origin == InteractionOrigin.semanticAgent &&
            {
              'propose',
              'adopt',
              'reject',
              'undo',
              'reapply',
              'leave',
              'reopen',
              'interaction',
            }.contains(action) &&
            (args['project'] == null || args['project'] != node?.id.value)) {
          throw const hc.WorkbenchRefusal('workbench_target_mismatch');
        }
        switch (action) {
          case 'open':
            await _open(args['project'] as String);
          case 'select':
            final id = args['object'] as String;
            if (id != 'project_open' &&
                node?.blockById(hc.NodeId(id)) == null) {
              throw const hc.WorkbenchRefusal('target_missing');
            }
            selected = id;
            inspect = true;
          case 'project':
            projection = hc.WorkProjection.values.byName(
              args['projection'] as String,
            );
          case 'propose':
            await _stage(
              args['operation'] as String,
              Map<String, dynamic>.from(args['arguments'] as Map),
              origin,
            );
          case 'adopt':
            candidate = null;
            await owner.adopt(node!.id.value, args['proposal'] as String);
            await _refresh();
          case 'reject':
            await owner.reject(node!.id.value, args['proposal'] as String);
            await _refresh();
          case 'undo':
            candidate = null;
            await owner.undo(node!.id.value, args['proposal'] as String);
            await _refresh();
          case 'reapply':
            candidate = null;
            proposal = await owner.reapply(
              node!.id.value,
              args['proposal'] as String,
              actor: origin.name,
            );
            await _refresh();
          case 'leave':
            await _leave();
          case 'reopen':
            await _reopen(candidate ?? behaviour);
          case 'interaction':
            final phase = args['phase'] as String;
            if (phase == 'begin') {
              final target = args['target'] as String;
              if (!['project_open', 'writing_width'].contains(target)) {
                throw const hc.WorkbenchRefusal(
                  'interaction_target_unsupported',
                );
              }
              final revision = args['revision'] as String;
              if (revision != hc.workRevision(node!)) {
                throw const hc.WorkbenchRefusal('interaction_target_stale');
              }
              _interaction = InteractionSession(
                id: args['id'] as String,
                target: target,
                revision: revision,
                origin: origin,
              )..begin();
            } else if (phase == 'cancel') {
              _cancel();
            } else {
              final active = _interaction;
              if (active == null) {
                throw const hc.WorkbenchRefusal('interaction_not_active');
              }
              if (phase == 'update') {
                active.update(
                  Map<String, Object?>.from(args['value'] as Map),
                  currentRevision: hc.workRevision(node!),
                );
              } else if (phase == 'end') {
                final value = active.end(
                  currentRevision: hc.workRevision(node!),
                );
                _interaction = null;
                final policy = {...behaviour.toJson(), ...value};
                if (active.target == 'project_open') {
                  final destination = args['destination'];
                  if (!['restore', 'remove_restore'].contains(destination)) {
                    throw const hc.WorkbenchRefusal('destination_incompatible');
                  }
                  policy['restore'] = destination == 'restore';
                }
                await _stage('return_behaviour', policy, origin);
              } else {
                throw const hc.WorkbenchRefusal('interaction_phase_invalid');
              }
            }
          case 'cancel':
            _cancel();
          default:
            throw const hc.WorkbenchRefusal('action_unsupported');
        }
      } on Object {
        ok = false;
        rethrow;
      }
    });
    return {'ok': ok, ..._state()};
  }

  void _cancel() {
    if (_interaction?.phase == InteractionPhase.active) _interaction!.cancel();
    _interaction = null;
    _dragWidth = null;
    candidate = null;
    inspect = false;
  }

  Future<void> _leave() async {
    final n = node!;
    final active = selected == 'project_open'
        ? (focusedBlock ??
              bookmark?['editor'] as String? ??
              (n.blocks.isEmpty ? null : n.blocks.first.id.value))
        : (selected ?? focusedBlock);
    final c = controllers[active];
    bookmark = {
      'version': 1,
      'selected': selected,
      'editor': active,
      'inspect': inspect,
      'offset': scroll.hasClients ? scroll.offset : 0.0,
      'cursor': (c?.selection.baseOffset ?? 0).clamp(0, c?.text.length ?? 0),
      'extent': (c?.selection.extentOffset ?? 0).clamp(0, c?.text.length ?? 0),
      'projection': projection.name,
      'revision': hc.workRevision(n),
      'content': active == null
          ? null
          : n.blockById(hc.NodeId(active))?.content,
    };
    await owner.saveView(n.id.value, bookmark!, viewerId: widget.viewerId);
    replay.add({
      'event': 'leave',
      'kind': 'fresh_execution',
      'position': bookmark,
    });
    await owner.recordObservation(n.id.value, replay.last, proposal: proposal);
    away = true;
  }

  Future<void> _reopen(hc.ReturnBehaviour policy) async {
    await _refresh();
    away = false;
    await _restorePosition(policy);
  }

  Future<void> _restorePosition(hc.ReturnBehaviour policy) async {
    if (policy.restore && bookmark != null) {
      final id = (bookmark!['editor'] ?? bookmark!['selected']) as String?;
      final block = id == null ? null : node!.blockById(hc.NodeId(id));
      final exact = bookmark!['revision'] == hc.workRevision(node!);
      if (block != null) {
        selected = bookmark!['selected'] as String? ?? id;
        focusedBlock = id;
        inspect = bookmark!['inspect'] as bool? ?? false;
        final c = controllers[id]!;
        final cursor = (bookmark!['cursor'] as int).clamp(0, c.text.length);
        final extent = (bookmark!['extent'] as int).clamp(0, c.text.length);
        final surviving = block.content == bookmark!['content'];
        c.selection = TextSelection(
          baseOffset: surviving ? cursor : 0,
          extentOffset: surviving ? extent : 0,
        );
        projection = hc.WorkProjection.values.byName(
          bookmark!['projection'] as String,
        );
        replay.add({
          'event': 'restore',
          'kind': 'observed',
          'exact': exact,
          'anchorSurvived': surviving,
          'cursor': c.selection.baseOffset,
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (scroll.hasClients) {
            scroll.jumpTo(
              exact
                  ? (bookmark!['offset'] as num).toDouble().clamp(
                      0,
                      scroll.position.maxScrollExtent,
                    )
                  : 0,
            );
          }
          if (policy.focus) focusNodes[id]?.requestFocus();
        });
        if (!surviving) {
          error =
              'Content changed; returned to the surviving block, at its beginning.';
        }
      } else {
        selected = null;
        inspect = false;
        projection = hc.WorkProjection.document;
        error = 'Previous object is missing; opened at the beginning.';
        replay.add({
          'event': 'restore',
          'kind': 'observed',
          'restored': false,
          'status': 'anchor_missing',
        });
      }
    } else {
      selected = null;
      inspect = false;
      projection = hc.WorkProjection.document;
      replay.add({'event': 'open', 'kind': 'observed', 'restored': false});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (scroll.hasClients) scroll.jumpTo(0);
        if (policy.focus && node!.blocks.isNotEmpty) {
          focusNodes[node!.blocks.first.id.value]?.requestFocus();
        }
      });
    }
    replayIndex = replay.length - 1;
    await owner.recordObservation(
      node!.id.value,
      replay.last,
      proposal: proposal,
    );

    if (mounted) setState(() {});
  }

  Future<void> _write(String id) async {
    final text = controllers[id]!.text;
    if (node!.blockById(hc.NodeId(id))!.content == text) return;
    await _stage('rewrite_block', {
      'block': id,
      'text': text,
    }, InteractionOrigin.surfaceInput);
    await owner.adopt(node!.id.value, proposal!);
    await _refresh();
  }

  Future<void> _delegate() async {
    if (harnessSession == null) {
      throw const hc.WorkbenchRefusal('select_live_harness_session');
    }
    final block = node!.blockById(hc.NodeId(selected ?? ''));
    if (block == null) throw const hc.WorkbenchRefusal('select_claim_first');
    // Sharing scope is explicit: only selected text and user-supplied source.
    final tools = HarnessSessionTools(
      registry: HarnessSessionRegistry.instance,
    );
    final receipt = tools.taskDelegate({
      'sessionId': harnessSession,
      'task':
          'Investigate this explicitly shared article scope. Project ${node!.id.value}; block ${block.id.value}. Claim: ${block.content}. Source: ${source.text}. Return evidence and a proposed rewrite; do not silently adopt. ${intent.text}',
    });
    if (receipt['ok'] != true) {
      throw hc.WorkbenchRefusal('${receipt['error'] ?? receipt['message']}');
    }
    harnessReceipt = jsonEncode(receipt);
    await owner.addKnowledge(
      node!.id.value,
      kind: hc.KnowledgeKind.question,
      text: intent.text.isEmpty ? 'Investigate selected claim' : intent.text,
      actor: 'local_surface',
      object: block.id.value,
      discussion: harnessSession,
    );
  }

  Widget _action(String label, VoidCallback? action, {String? key}) =>
      TextButton(
        key: ValueKey(key ?? label),
        onPressed: busy ? null : action,
        style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
        child: Text(workbenchText(context, label)),
      );

  Widget _document() {
    final n = node!;
    if (away) {
      return Center(
        child: _action(
          'Reopen project',
          () => unawaited(_run(() => _reopen(candidate ?? behaviour))),
        ),
      );
    }
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.all(24),
      children: [
        for (final b in n.blocks)
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (inspect)
                      SizedBox(
                        width: 44,
                        child: _action(
                          'Select',
                          () => setState(() => selected = b.id.value),
                          key: 'select-${b.id.value}',
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        key: ValueKey('block-${b.id.value}'),
                        controller: controllers[b.id.value],
                        focusNode: focusNodes[b.id.value],
                        minLines: 1,
                        maxLines: null,
                        onTap: () => setState(() {
                          selected = b.id.value;
                          focusedBlock = b.id.value;
                        }),
                        onSubmitted: (_) =>
                            unawaited(_run(() => _write(b.id.value))),
                        onTapOutside: (_) {
                          focusNodes[b.id.value]?.unfocus();
                          unawaited(_run(() => _write(b.id.value)));
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: inspect ? b.type.name : null,
                        ),
                        style: TextStyle(
                          fontSize: b.type == hc.BlockType.heading ? 26 : 20,
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (inspect)
                      Semantics(
                        label: 'Writing width boundary',
                        child: GestureDetector(
                          key: const ValueKey('writing-width-handle'),
                          onHorizontalDragStart: (_) {
                            _interaction = InteractionSession(
                              id: const Uuid().v4(),
                              target: 'writing_width',
                              revision: hc.workRevision(n),
                              origin: InteractionOrigin.surfaceInput,
                            )..begin();
                            _dragWidth = behaviour.width;
                          },
                          onHorizontalDragUpdate: (d) {
                            setState(
                              () => _dragWidth = (width + d.delta.dx * 2).clamp(
                                320,
                                1200,
                              ),
                            );
                            _interaction?.update({
                              'width': width,
                            }, currentRevision: hc.workRevision(node!));
                          },
                          onHorizontalDragCancel: () => setState(_cancel),
                          onHorizontalDragEnd: (_) {
                            _interaction?.end(
                              currentRevision: hc.workRevision(node!),
                            );
                            final value = width;
                            _dragWidth = null;
                            unawaited(
                              _run(
                                () => _stage('return_behaviour', {
                                  ...behaviour.toJson(),
                                  'width': value,
                                }, InteractionOrigin.surfaceInput),
                              ),
                            );
                          },
                          child: const SizedBox(
                            width: 24,
                            height: 64,
                            child: Center(child: Text('│')),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _inspector() {
    final block = node!.blockById(hc.NodeId(selected ?? ''));
    final proposals =
        Map<String, dynamic>.from(metadata['proposals'] as Map? ?? {}).map(
          (key, value) =>
              MapEntry(key, Map<String, dynamic>.from(value as Map)),
        );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: workbenchText(context, 'Inspect object'),
            child: DropdownButton<String>(
              key: const ValueKey('inspect-object'),
              isExpanded: true,
              value: block?.id.value ?? 'project_open',
              items: [
                DropdownMenuItem(
                  value: 'project_open',
                  child: Text(
                    workbenchText(context, 'Project opening behaviour'),
                  ),
                ),
                for (final entry in node!.blocks.indexed)
                  DropdownMenuItem(
                    value: entry.$2.id.value,
                    child: Text(
                      '${entry.$1 + 1}. ${entry.$2.content.split('\n').first}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: busy ? null : (id) => setState(() => selected = id),
            ),
          ),
          if (projection == hc.WorkProjection.spatial)
            WorkbenchScene(
              onSelect: (_) => setState(() => selected = 'project_open'),
              onWidthDelta: (dx) => setState(
                () => _dragWidth = (width + dx * 2).clamp(320, 1200),
              ),
              onEnd: (cancelled) {
                final value = width;
                setState(() => _dragWidth = null);
                if (!cancelled) {
                  unawaited(
                    _run(
                      () => _stage('return_behaviour', {
                        ...behaviour.toJson(),
                        'width': value,
                      }, InteractionOrigin.surfaceInput),
                    ),
                  );
                }
              },
            ),
          Text(
            selected == 'project_open'
                ? 'Project opening behaviour'
                : 'Selected work',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (block != null) ...[
            Text(
              '${block.type.name} · ${block.id.value}',
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                _action(
                  'Move up',
                  () => unawaited(
                    _run(
                      () => _stage('move_block', {
                        'block': block.id.value,
                        'destination': (node!.blocks.indexOf(block) - 1).clamp(
                          0,
                          node!.blocks.length - 1,
                        ),
                      }, InteractionOrigin.surfaceInput),
                    ),
                  ),
                ),
                _action(
                  'Move down',
                  () => unawaited(
                    _run(
                      () => _stage('move_block', {
                        'block': block.id.value,
                        'destination': (node!.blocks.indexOf(block) + 1).clamp(
                          0,
                          node!.blocks.length - 1,
                        ),
                      }, InteractionOrigin.surfaceInput),
                    ),
                  ),
                ),
              ],
            ),
            if (block.type == hc.BlockType.heading)
              DropdownButton<String>(
                hint: const Text('Move section before'),
                isExpanded: true,
                items: [
                  for (final heading in node!.blocks)
                    if (heading.type == hc.BlockType.heading &&
                        heading.id != block.id)
                      DropdownMenuItem(
                        value: heading.id.value,
                        child: Text(
                          heading.content,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                ],
                onChanged: (id) {
                  if (id != null) {
                    unawaited(
                      _run(
                        () => _stage('move_section', {
                          'block': block.id.value,
                          'before': id,
                        }, InteractionOrigin.surfaceInput),
                      ),
                    );
                  }
                },
              ),
            if (block.type == hc.BlockType.paragraph)
              _action(
                'Split at cursor',
                () => unawaited(
                  _run(
                    () => _stage('split_block', {
                      'block': block.id.value,
                      'offset':
                          controllers[block.id.value]!.selection.baseOffset,
                      'newId': const Uuid().v4(),
                    }, InteractionOrigin.surfaceInput),
                  ),
                ),
              ),
            TextField(
              controller: source,
              decoration: InputDecoration(
                labelText: workbenchText(
                  context,
                  'Evidence source (URL or project reference)',
                ),
              ),
            ),
            Wrap(
              children: [
                for (final relation in hc.EvidenceRelation.values)
                  _action(
                    relation.name,
                    () => unawaited(
                      _run(() async {
                        await owner.linkEvidence(
                          node!.id.value,
                          claim: block.id.value,
                          source: source.text,
                          relation: relation,
                          actor: 'local_surface',
                        );
                        await _refresh();
                      }),
                    ),
                  ),
              ],
            ),
            for (final link in (metadata['links'] as List? ?? []).map(
              (value) => Map<String, dynamic>.from(value as Map),
            ))
              if (link['claim'] == block.id.value)
                Text('${link['relation']}: ${link['source']}'),
            if (widget.collaboration)
              _action(
                'Start scoped investigation',
                () => setState(() {
                  sharedScope = SharedWorkbenchScope(
                    project: node!.id.value,
                    block: block.id.value,
                    content: block.content,
                  );
                }),
              ),
            TextField(
              controller: intent,
              decoration: InputDecoration(
                labelText: workbenchText(context, 'Question or change intent'),
              ),
            ),
            DropdownButton<String>(
              value: harnessSession,
              hint: Text(workbenchText(context, 'Live harness session')),
              isExpanded: true,
              items: HarnessSessionRegistry.instance.sessions.keys
                  .map(
                    (id) => DropdownMenuItem(
                      value: id,
                      child: Text(id, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (id) => setState(() => harnessSession = id),
            ),
            _action(
              'Share selected scope and investigate',
              () => unawaited(_run(_delegate)),
            ),
            if (harnessReceipt != null) Text(harnessReceipt!),
          ],
          const SizedBox(height: 20),
          BehaviourConnection(
            restore: (candidate ?? behaviour).restore,
            onStage: (value) {
              candidate = hc.ReturnBehaviour(
                restore: value,
                focus: (candidate ?? behaviour).focus,
                width: (candidate ?? behaviour).width,
              );
              unawaited(
                _run(
                  () => _stage(
                    'return_behaviour',
                    candidate!.toJson(),
                    InteractionOrigin.surfaceInput,
                  ),
                ),
              );
            },
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(workbenchText(context, 'Restore position')),
            value: (candidate ?? behaviour).restore,
            onChanged: (v) => setState(
              () => candidate = hc.ReturnBehaviour(
                restore: v!,
                focus: (candidate ?? behaviour).focus,
                width: (candidate ?? behaviour).width,
              ),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(workbenchText(context, 'Focus editor')),
            value: (candidate ?? behaviour).focus,
            onChanged: (v) => setState(
              () => candidate = hc.ReturnBehaviour(
                restore: (candidate ?? behaviour).restore,
                focus: v!,
                width: (candidate ?? behaviour).width,
              ),
            ),
          ),
          Text('Reading width: ${width.round()}'),
          Slider(
            min: 320,
            max: 1200,
            value: (candidate ?? behaviour).width,
            onChanged: (v) => setState(
              () => candidate = hc.ReturnBehaviour(
                restore: (candidate ?? behaviour).restore,
                focus: (candidate ?? behaviour).focus,
                width: v,
              ),
            ),
          ),
          _action(
            'Stage behaviour',
            () => unawaited(
              _run(
                () => _stage(
                  'return_behaviour',
                  (candidate ?? behaviour).toJson(),
                  InteractionOrigin.surfaceInput,
                ),
              ),
            ),
          ),
          _action('Leave (save position)', () => unawaited(_run(_leave))),
          _action(
            'Reopen with candidate',
            () => unawaited(_run(() => _reopen(candidate ?? behaviour))),
          ),
          const SizedBox(height: 16),
          Text(
            workbenchText(context, 'Proposals · adoption changes this project'),
          ),
          for (final value in proposals.values) ...[
            Text('${value['intent']} · ${value['status']} · ${value['actor']}'),
            if (value['after'] != null && value['status'] == 'staged')
              Text(
                hc.DocumentNode.fromJson(
                  Map<String, dynamic>.from(value['after'] as Map),
                ).blocks.map((b) => b.content).join('\n'),
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            Wrap(
              children: [
                if (value['status'] == 'staged')
                  _action(
                    'Adopt',
                    () => unawaited(
                      _act('adopt', {
                        'proposal': value['id'],
                      }, InteractionOrigin.surfaceInput),
                    ),
                    key: 'adopt-${value['id']}',
                  ),
                if (['staged', 'stale'].contains(value['status']))
                  _action(
                    'Reject',
                    () => unawaited(
                      _act('reject', {
                        'proposal': value['id'],
                      }, InteractionOrigin.surfaceInput),
                    ),
                    key: 'reject-${value['id']}',
                  ),
                if (value['status'] == 'adopted')
                  _action(
                    'Undo',
                    () => unawaited(
                      _act('undo', {
                        'proposal': value['id'],
                      }, InteractionOrigin.surfaceInput),
                    ),
                    key: 'undo-${value['id']}',
                  ),
                if (value['status'] == 'undone')
                  _action(
                    'Reapply',
                    () => unawaited(
                      _act('reapply', {
                        'proposal': value['id'],
                      }, InteractionOrigin.surfaceInput),
                    ),
                    key: 'reapply-${value['id']}',
                  ),
              ],
            ),
          ],
          if (replay.isNotEmpty) ...[
            Text(
              workbenchText(
                context,
                'Recorded observations · stepping does not re-execute',
              ),
            ),
            Text(jsonEncode(replay[replayIndex])),
            Wrap(
              children: [
                _action(
                  'Previous',
                  replayIndex > 0 ? () => setState(() => replayIndex--) : null,
                ),
                _action(
                  'Next',
                  replayIndex < replay.length - 1
                      ? () => setState(() => replayIndex++)
                      : null,
                ),
              ],
            ),
          ],
          _action(
            'Return to writing',
            () => setState(() {
              inspect = false;
              projection = hc.WorkProjection.document;
            }),
          ),
        ],
      ),
    );
  }

  Widget _projectPicker() => FutureBuilder<List<hc.NodeId>>(
    future: context.read<hc.DocumentRepository>().childrenOf(null),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Project index unavailable: ${snapshot.error}');
      }
      final ids = snapshot.data ?? <hc.NodeId>[];
      return ListView.builder(
        itemCount: ids.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(workbenchText(context, 'Choose project work')),
            );
          }
          final id = ids[index - 1];
          return FutureBuilder<hc.DocResult>(
            future: context.read<hc.DocumentRepository>().get(id),
            builder: (context, result) {
              final value = result.data;
              if (value is! hc.DocFound ||
                  value.node.kind == 'workbench_metadata') {
                return const SizedBox.shrink();
              }
              return FutureBuilder<Map<String, dynamic>>(
                future: owner.state(id.value),
                builder: (context, work) {
                  final proposals = (work.data?['proposals'] as Map? ?? {})
                      .values
                      .whereType<Map>();
                  final open = proposals
                      .where(
                        (p) =>
                            p['status'] == 'staged' || p['status'] == 'stale',
                      )
                      .length;
                  return ListTile(
                    title: Text(
                      value.node.blocks.isEmpty
                          ? id.value
                          : value.node.blocks.first.content,
                    ),
                    subtitle: Text(
                      work.hasError
                          ? 'State unavailable: ${work.error}'
                          : '$open proposals awaiting a decision',
                    ),
                    onTap: () => unawaited(_run(() => _open(id.value))),
                  );
                },
              );
            },
          );
        },
      );
    },
  );

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () => setState(_cancel),
    },
    child: Focus(
      autofocus: true,
      child: Scaffold(
        appBar: AppBar(title: Text(workbenchText(context, 'Workbench'))),
        body: Column(
          children: [
            Wrap(
              children: [
                _action(
                  'Open sample article',
                  () => unawaited(_run(_createSample)),
                ),
                _action(
                  inspect ? 'Focus writing' : 'Inspect',
                  node == null
                      ? null
                      : () => setState(() {
                          inspect = !inspect;
                          selected ??= 'project_open';
                        }),
                ),
              ],
            ),
            if (busy) const LinearProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(error!, key: const ValueKey('workbench-error')),
              ),
            if (node != null)
              Wrap(
                children: [
                  for (final p in hc.WorkProjection.values)
                    _action(
                      p.name,
                      () => setState(() {
                        projection = p;
                        inspect = p != hc.WorkProjection.document;
                      }),
                    ),
                  _action(
                    'Project opening connection',
                    () => setState(() {
                      selected = 'project_open';
                      inspect = true;
                    }),
                  ),
                ],
              ),
            Expanded(
              child: sharedScope != null
                  ? Column(
                      children: [
                        _action(
                          'Return to project',
                          () => unawaited(
                            _run(() async {
                              sharedScope = null;
                              await _refresh();
                            }),
                          ),
                        ),
                        Expanded(
                          child: WorkbenchInvestigation(
                            owner: owner,
                            scope: sharedScope!,
                          ),
                        ),
                      ],
                    )
                  : node == null
                  ? _projectPicker()
                  : LayoutBuilder(
                      builder: (context, size) {
                        if (!inspect) return _document();
                        if (size.maxWidth >= 900) {
                          return Row(
                            children: [
                              Expanded(child: _document()),
                              SizedBox(width: 380, child: _inspector()),
                            ],
                          );
                        }
                        return _inspector();
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
