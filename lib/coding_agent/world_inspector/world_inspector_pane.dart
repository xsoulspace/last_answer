import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
// The guarded external-worlds attach: VM reads real manifests (dart:io);
// web answers honest absence (stub). Never a compile error on web.
import 'package:lastanswer/coding_agent/world_inspector/external_worlds_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/world_inspector/external_worlds_io.dart'
    as external_worlds;
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding_sheet.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_seats.dart';
import 'package:xsoulspace_agentic_harness_inspector/session_protocol.dart';
// Deep imports are the package's DOCUMENTED web-safe pattern: the barrel
// also carries dart:io transports (mcp_source/app_server) that must never
// enter a web build.
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/answer_rail.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/app.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/command_palette.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/inspector_theme.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/source.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/trace.dart';
// ignore: implementation_imports
import 'package:xsoulspace_agentic_harness_inspector/src/world_scene.dart'
    show AttachSceneBand, ScenePalette, SceneTier;
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// The world inspector pane — the harness's Tufte inspector EMBEDDED under
/// the agent doc (inspector DESIGN.md "Boundary 2026-10-05 rev. 3": ONE
/// version, the 3D one; this product repo builds no parallel renderer).
///
/// What it renders: the live doc-bound world as the inspector sees it —
/// 2D bands (actor budget strips, the decision/tool view) over the 3D
/// world band, fed by a [RegistrySource] polling the ONE session registry
/// (ADR 0009; the focused/only session). Verbs stay product-side: talking
/// to an actor, answering permissions — the doc surface above owns those.
///
/// Attention dial (product DESIGN §10): collapsed, the pane is ONE status
/// rule — the top fleet-level need when one exists (`1 needs you · perm:
/// …`, L0, the Answer Rail's top row), else the session counts. The rule
/// is the loudest quiet thing and tap-to-act: tapping it expands AND
/// aligns the canvas on the actor the need names. Expanding opens the
/// inspector in world-as-canvas mode (S2): the 3D scene owns the surface,
/// the ranked Answer Rail floats on its left edge, and the 2D bands
/// become slates DOCKED beside the rail (never covering the world). The
/// interaction model is the owner's vosges law — NOT a talking
/// assistant: gestures name intents (tap an actor = select, hold = the
/// intent palette pre-filtered to it, scroll = altitude, flick = scrub);
/// the bench shows, the grammar executes. Widget keys are the agent's UI
/// contract: `world_inspector.rule` / `.toggle` / `.pane`.
///
/// Web note: deep imports only (the package barrel carries dart:io
/// transports — mcp_source/app_server — that must not enter a web build).
class WorldInspectorPane extends StatefulWidget {
  const WorldInspectorPane({
    super.key,
    this.registry,
    this.pollInterval = const Duration(milliseconds: 500),
    this.expandedHeight = 360.0,
    this.showScene = true,
    this.binding,
    this.bindingSourceBuilder,
    this.onBindingChanged,
  });

  /// The registry to observe; null → the shared instance (the one index
  /// the doc surfaces register under).
  final HarnessSessionRegistry? registry;

  final Duration pollInterval;

  /// Finite heights retain the embedded pane size. Infinity fills the bounded
  /// space supplied by the fullscreen caller, below this pane's status rule.
  final double expandedHeight;

  /// False replaces the 3D band with the honest off placeholder — data-flow
  /// and layout tests run without scene static resources (the InspectorApp
  /// law). Production leaves it true: ONE version, the 3D one.
  final bool showScene;

  /// The doc's bound EXTERNAL world (the doc payload's `worldBinding`):
  /// when set, the pane samples THAT world's http facade instead of the
  /// in-process registry — the doc chooses what it connects to (user
  /// decision, never a hardcoded world). Null = the embedded default.
  final WorldBindingModel? binding;

  /// Test seam: builds the read source for a binding. Null → the real
  /// http facade route ([sourceForBinding]) — the same seam shape the
  /// host config's handlerFactory uses (scripted fixture, never a
  /// second protocol).
  final TraceSource Function(WorldBindingModel binding)? bindingSourceBuilder;

  /// The binding changed through the pane's connect affordance — the
  /// caller (the doc surface's composition point) persists it into the
  /// doc payload.
  final ValueChanged<WorldBindingModel?>? onBindingChanged;

  /// The latest projection, refreshed every build — the headless read for
  /// the `world_inspector_state` debug verb (equal readers, ADR 0009 D3).
  static WorldInspectorProjection? lastProjection;

  /// An EXTERNAL harness world to observe instead of the in-process
  /// registry (ZCode/Codex seat-spawned daemons publish manifests at
  /// `~/.xsoulspace/worlds/`; see [resolveExternal]). Debug verbs set
  /// this; the pane re-samples within one poll tick. Read-only by
  /// construction: the palette lists no verbs for an external source.
  static final ValueNotifier<TraceSource?> externalOverride =
      ValueNotifier<TraceSource?>(null);

  /// The live pane for intent-driven actions (`app_inspector`) — set
  /// while a pane is mounted, cleared with the identical guard (the
  /// AgentDocSurface.debugSurface pattern; several docs may be open —
  /// the LAST mounted pane answers, which is also the visible one).
  static _WorldInspectorPaneState? debugSurface;

  /// The attachable EXTERNAL world for [worldId] (null = first live
  /// world): manifest scan → the PAIRED-WORLD registry (ADR 0072,
  /// off-device) → the http facade route ONLY — an embed never spawns a
  /// daemon; no facade means the honest refusal "arm `harnessd
  /// --serve`". Discovery never grants authority.
  static Future<TraceSource?> resolveExternal({final String? worldId}) =>
      external_worlds.resolveExternalAsync(worldId: worldId);

  @override
  State<WorldInspectorPane> createState() => _WorldInspectorPaneState();
}

class _WorldInspectorPaneState extends State<WorldInspectorPane> {
  bool _expanded = false;
  bool _paletteOpen = false;

  /// The VOSGES hold seed: an actor held on the canvas opens the intent
  /// palette pre-filtered to that actor (a gesture names an intent; the
  /// one verb grammar executes it). Null = the palette opens unfiltered.
  String? _paletteSeed;
  InspectorTrace? _trace;
  RegistrySource? _source;
  Timer? _timer;

  /// The bound world re-resolved against the live roster (token +
  /// seatWs are device-local trust — the doc payload never carries
  /// them). Null = the world answered nothing YET (first sample) or is
  /// gone; the rule says which.
  DiscoveredWorld? _discovered;

  /// The bound world's last sample: null while nothing ever landed
  /// (unreachable or not-yet-armed — the honest state the rule names).
  InspectorTrace? _bindingTrace;

  /// The canvas-wide selection (P0 alignment) — rail taps write it; the
  /// scene band and the view slate read the same value.
  final ValueNotifier<String?> _selection = ValueNotifier<String?>(null);

  /// The altitude seam (S3 hoisted to the canvas control column): the
  /// band publishes the effective tier; a chip tap writes the override.
  final ValueNotifier<SceneTier> _altitude = ValueNotifier<SceneTier>(
    SceneTier.steps,
  );
  final ValueNotifier<SceneTier?> _altitudeOverride = ValueNotifier<SceneTier?>(
    null,
  );

  HarnessSessionRegistry get _registry =>
      widget.registry ?? HarnessSessionRegistry.instance;

  @override
  void initState() {
    super.initState();
    WorldInspectorPane.debugSurface = this;
    _source = RegistrySource(registry: _registry);
    WorldInspectorPane.externalOverride.addListener(_onExternalChanged);
    _rebinding(widget.binding, null);
    _poll();
    _timer = Timer.periodic(widget.pollInterval, (_) => _poll());
  }

  /// Re-resolves the device-local trust for a (new) binding.
  void _rebinding(final WorldBindingModel? next, final Object? _) {
    if (next == null) {
      _discovered = null;
      _bindingTrace = null;
      return;
    }
    unawaited(
      external_worlds.rediscover(next).then((final world) {
        if (mounted) setState(() => _discovered = world);
      }),
    );
  }

  @override
  void didUpdateWidget(final WorldInspectorPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.binding != widget.binding) {
      _rebinding(widget.binding, null);
    }
  }

  void _onExternalChanged() {
    if (mounted) setState(() {});
  }

  /// Source precedence: the doc's binding first (the doc chose its
  /// world), then the debug-verb override, then the embedded registry.
  TraceSource get _activeSource {
    final binding = widget.binding;
    if (binding != null) {
      final builder = widget.bindingSourceBuilder;
      if (builder != null) return builder(binding);
      return sourceForBinding(binding, token: _discovered?.token ?? '');
    }
    return WorldInspectorPane.externalOverride.value ?? _source!;
  }

  @override
  void dispose() {
    if (identical(WorldInspectorPane.debugSurface, this)) {
      WorldInspectorPane.debugSurface = null;
    }
    WorldInspectorPane.externalOverride.removeListener(_onExternalChanged);
    _timer?.cancel();
    unawaited(_source?.close());
    super.dispose();
  }

  /// Opens the world picker (the ONE connect surface): pick a world,
  /// add an endpoint, or return to the embedded world.
  Future<void> _connect() async {
    final choice = await showWorldBindingSheet(
      context,
      current: widget.binding,
    );
    if (!choice.picked) return;
    widget.onBindingChanged?.call(choice.binding);
    if (mounted) setState(() {});
  }

  Future<Map<String, Object?>> attachWorld(String worldId) async {
    final roster = await external_worlds.discoverWorlds();
    final world = roster.where((world) => world.worldId == worldId).firstOrNull;
    if (world == null || widget.onBindingChanged == null) {
      return {'ok': false, 'bounce': 'world_binding_unavailable'};
    }
    widget.onBindingChanged!(world.toBinding());
    return {'ok': true, 'worldId': worldId, 'participating': true};
  }

  /// Intent surface (`app_inspector`): expand/collapse the pane. Pass
  /// [expand] to force a state (null toggles); false when unmounted.
  bool toggleFromIntent({final bool? expand}) {
    if (!mounted) return false;
    setState(() => _expanded = expand ?? !_expanded);
    return _expanded;
  }

  /// Intent surface (`app_inspector`): open/close the intent palette.
  bool paletteFromIntent({required final bool open}) {
    if (!mounted) return false;
    setState(() {
      _paletteOpen = open;
      if (!open) _paletteSeed = null;
    });
    return _paletteOpen;
  }

  void _poll() {
    unawaited(
      _activeSource
          .sample()
          .then((trace) {
            if (!mounted || trace == null) return;
            if (widget.binding != null) {
              setState(() => _bindingTrace = trace);
            } else {
              setState(() => _trace = trace);
            }
          })
          .catchError((Object _) => null),
    );
  }

  /// The trace the pane renders: the bound world's sample when bound,
  /// the in-process registry's otherwise.
  InspectorTrace? get _visibleTrace =>
      widget.binding != null ? _bindingTrace : _trace;

  /// True while a bound world has never produced a sample — unreachable
  /// facade, wrong endpoint, or the world is gone. The rule names it.
  bool get _bindingUnreachable =>
      widget.binding != null && _bindingTrace == null;

  void _toggle() => setState(() => _expanded = !_expanded);

  /// The palette's roster — the product's verbs as data: answer/reject
  /// for every pending permission, delegate for every running session.
  /// The inspector RENDERS these; execution routes through the registry
  /// HERE (verbs stay product-side, the boundary law). A bound world
  /// with an advertised seat channel gains ONE write verb: delegate
  /// through the seat (ADR 0072 §5) — the read-only pane's only
  /// escalation, and only because the PAIRING earned it.
  List<InspectorCommand> _commands(List<WorldInspectorSession> sessions) => [
    if (widget.binding != null && (_discovered?.hasSeat ?? false))
      InspectorCommand(
        id: 'delegate:seat',
        label: 'delegate — ${widget.binding!.worldId} (via seat)',
        hint: 'the typed line IS the task sentence',
      ),
    for (final s in sessions) ...[
      if (s.pendingPermission != null) ...[
        InspectorCommand(
          id: 'perm:allow:${s.id}',
          label: 'allow — ${s.pendingPermission}',
          hint: s.id,
        ),
        InspectorCommand(
          id: 'perm:reject:${s.id}',
          label: 'reject — ${s.pendingPermission}',
          hint: '${s.id} · the change never lands',
          dangerous: true,
        ),
      ],
      if (s.running)
        InspectorCommand(
          id: 'delegate:${s.id}',
          label: 'delegate to ${s.id}',
          hint: 'the typed line IS the task sentence',
        ),
    ],
  ];

  /// The earned seat for the bound world (cached — one grant per pane).
  WorldSeatLease? _seatLease;

  /// The WRITE rung for a bound world: delegate the task sentence
  /// through the paired world's seat channel. The outcome surfaces
  /// honestly (accepted / refused / failed — named, never silent).
  Future<void> _delegateViaSeat(final String sentence) async {
    final bound = widget.binding;
    final world = _discovered;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (bound == null || world == null || !world.hasSeat) return;
    try {
      _seatLease ??= await WorldSeatChannel.request(
        seatWs: world.seatWs,
        token: world.token,
      );
      final lease = _seatLease;
      if (lease == null) {
        messenger?.showSnackBar(
          const SnackBar(content: Text('seat: no channel — read-only world')),
        );
        return;
      }
      final result = await WorldSeatChannel.call(
        lease,
        seatWs: world.seatWs,
        token: world.token,
        name: 'agent_task_delegate',
        args: {'task': sentence},
      );
      final ok = result['ok'] == true;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'seat · ${bound.worldId}: '
            '${ok ? 'task accepted' : 'refused'} '
            '${ok ? '' : result['bounce'] ?? result}',
          ),
        ),
      );
    } on Object catch (e) {
      // A refused/failed seat must not strand silently — and a stale
      // credential is dropped so the next attempt earns a fresh one.
      _seatLease = null;
      messenger?.showSnackBar(
        SnackBar(
          content: Text('seat failed: ${e.toString().split('\n').first}'),
        ),
      );
    }
  }

  void _runCommand(InspectorCommand command, String query) {
    if (command.id == ':esc') {
      setState(() => _paletteOpen = false);
      return;
    }
    final parts = command.id.split(':');
    if (parts.length == 2 && parts[0] == 'delegate' && parts[1] == 'seat') {
      final sentence = query.trim();
      setState(() => _paletteOpen = false);
      if (sentence.isNotEmpty) unawaited(_delegateViaSeat(sentence));
      return;
    }
    final handle = parts.length == 3
        ? _registry.sessions[parts.sublist(2).join(':')]
        : _registry.sessions[parts.elementAt(1)];
    if (parts[0] == 'perm' && handle != null) {
      handle.answerPermission(allow: parts[1] == 'allow');
    } else if (parts[0] == 'delegate' && handle != null) {
      final sentence = query.trim();
      if (sentence.isNotEmpty) handle.delegateTask(sentence);
    }
    setState(() => _paletteOpen = false);
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final bound = widget.binding;
    // A bound EXTERNAL world is observed, never operated: the palette
    // lists no verbs for it (the write rung rides the seat explicitly —
    // G), and the registry's sessions are ANOTHER world's data.
    final List<WorldInspectorSession> sessions;
    if (bound == null) {
      sessions =
          _registry.sessions.values
              .map(
                (final handle) =>
                    WorldInspectorSession.of(handle, keyOf: _keyOf(handle)),
              )
              .toList()
            ..sort((final a, final b) => a.id.compareTo(b.id));
    } else {
      sessions = const <WorldInspectorSession>[];
    }
    final trace = _visibleTrace;
    final running = sessions.where((final s) => s.running).length;
    final pending = sessions
        .where((final s) => s.pendingPermission != null)
        .length;
    // The fleet-level Answer Rail (S2): attention needs only — a pending
    // permission or a failed verdict. Running/claims are ambient; they
    // rank in the in-canvas rail, they never shout from the rule.
    // The SAME list feeds the status rule AND the in-canvas rail (the
    // ONE needs source law — the bench never contradicts itself).
    final needs = [
      for (final s in sessions) ...[
        if (s.pendingPermission != null)
          WorldInspectorNeed(
            severity: 'permission',
            title:
                'perm: ${s.pendingPermission}'
                '${s.waiting == null ? '' : ' · ${s.waiting}'} · ${s.id}',
            actorId: s.id,
          ),
        if (s.verdict != null && s.verdict!.toLowerCase().contains('fail'))
          WorldInspectorNeed(
            severity: 'failed',
            title: 'fail: ${s.verdict} · ${s.id}',
            actorId: s.id,
          ),
      ],
    ]..sort((final a, final b) => a.rank.compareTo(b.rank));
    // The rail's rows: two lines per need (title, then waiting/actor).
    final railNeeds = [
      for (final n in needs)
        AnswerItem(
          severity: n.severity == 'permission'
              ? AnswerSeverity.permission
              : AnswerSeverity.failed,
          title: n.title.split(' · ${n.actorId}').first,
          detail: n.actorId,
          actorId: n.actorId,
        ),
    ];
    WorldInspectorPane.lastProjection = WorldInspectorProjection(
      sessions: sessions,
      needs: needs,
      sampledRows: trace?.rows.length ?? 0,
      sampledSession: '${trace?.metrics['sessionId'] ?? ''}',
      expanded: _expanded,
      sampleError: _bindingUnreachable
          ? StateError(
              'bound world ${bound?.worldId} unreachable — is the facade '
              'armed at ${bound?.endpoint}?',
            )
          : RegistrySource.lastError,
    );
    return Column(
      key: const Key('world_inspector.root'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 0.6, color: theme.dividerColor),
        InkWell(
          key: const Key('world_inspector.toggle'),
          // Tap-to-act (audit 3): expanding on a need aligns the canvas
          // on the actor that need names — the rule is the door, not a
          // caption.
          onTap: () {
            if (!_expanded && needs.isNotEmpty) {
              final top = needs.first.actorId;
              if (top != null) _selection.value = top;
            }
            _toggle();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Row(
              children: [
                Text(
                  bound != null
                      ? 'WORLD · '
                            '${(bound.displayName.isNotEmpty ? bound.displayName : bound.worldId).toUpperCase()}'
                      : WorldInspectorPane.externalOverride.value == null
                      ? 'WORLD'
                      : 'WORLD · EXTERNAL (read-only)',
                  key: const Key('world_inspector.rule'),
                  style: _label(theme).copyWith(
                    color: _expanded
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: _expanded ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                // The connect affordance (the ONE connect surface): pick
                // a world, add an endpoint, or return to the embedded
                // one. Present in every state — changing the binding is
                // always one tap away.
                GestureDetector(
                  key: const Key('world_inspector.connect'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _connect,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, right: 4),
                    child: Icon(
                      Icons.link_outlined,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Builder(
                    builder: (final context) {
                      final quiet = _mono(
                        theme,
                        color: needs.isNotEmpty || pending > 0
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      );
                      if (bound != null) {
                        // The bound world's honest line: what sampled,
                        // or WHY nothing did (names the arm command).
                        if (_bindingUnreachable) {
                          return Text(
                            'unreachable — arm `harnessd --serve` at '
                            '${bound.endpoint}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: quiet,
                          );
                        }
                        return Text(
                          '${trace?.rows.length ?? 0} row(s) · '
                          '${trace?.metrics['sessionId'] ?? bound.worldId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: quiet,
                        );
                      }
                      final attention = needs.length == 1
                          ? '1 needs you'
                          : '${needs.length} need you';
                      if (sessions.isEmpty) {
                        return Text(
                          'no live sessions — delegate a task from the doc',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: quiet,
                        );
                      }
                      if (needs.isEmpty) {
                        return Text(
                          '${sessions.length} session(s) · $running running',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: quiet,
                        );
                      }
                      // The promoted need (audit 3): the one line that
                      // matters is the LOUDEST quiet thing — bigger ink,
                      // weight, and a severity dot (amber = asks before
                      // it acts, red = an outcome named a failure).
                      final top = needs.first;
                      return RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '● ',
                              style: quiet.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: top.severity == 'failed'
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.tertiary,
                              ),
                            ),
                            TextSpan(
                              text: '$attention · ${top.title}',
                              style: quiet.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Text(_expanded ? 'hide' : 'inspect', style: _label(theme)),
                // S4 — the one grammar: the palette opens over the canvas
                // and its roster IS the product's verb set (allow/reject/
                // delegate for the live sessions). Verbs execute HERE,
                // through the registry — the inspector stays read-only.
                if (_expanded)
                  Semantics(
                    container: true,
                    explicitChildNodes: true,
                    button: true,
                    label: 'inspector palette',
                    textDirection: TextDirection.ltr,
                    child: GestureDetector(
                      key: const Key('world_inspector.palette-toggle'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _paletteOpen = !_paletteOpen),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '⌘K',
                          style: _label(theme).copyWith(
                            color: _paletteOpen
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          Container(height: 0.6, color: theme.dividerColor),
          _expandedCanvas(
            child: LayoutBuilder(
              builder: (final context, final canvas) {
                // The canvas width decides the palette's bound (a
                // right-only Positioned child sees unbounded constraints
                // — LayoutBuilder must sit HERE, at the canvas, measured
                // 2026-10-05).
                final paletteWidth = (canvas.maxWidth - 264 - 24).clamp(
                  240.0,
                  340.0,
                );
                return Stack(
                  textDirection: TextDirection.ltr,
                  children: [
                    Positioned.fill(
                      child: _visibleTrace == null
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'nothing sampled yet — the bands and the 3D '
                                'world appear once a session is resolvable '
                                '(open/only or focused)',
                                style: _mono(
                                  theme,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Builder(
                              // S1 — the material: the embedded inspector
                              // adopts the HOST's brightness (night in
                              // this app's dark theme), never a pasted-in
                              // daylight box.
                              builder: (final context) {
                                final night =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                // The bench remembers per world: a bound
                                // doc keys by its world, the embedded
                                // registry by 'doc'.
                                final worldKey =
                                    bound?.worldId ??
                                    (WorldInspectorPane
                                                .externalOverride
                                                .value ==
                                            null
                                        ? 'doc'
                                        : 'external');
                                return InspectorApp(
                                  trace: _visibleTrace,
                                  theme: night
                                      ? InspectorTheme.night
                                      : InspectorTheme.day,
                                  worldAsCanvas: true,
                                  selected: _selection,
                                  altitude: _altitude,
                                  altitudeOverride: _altitudeOverride,
                                  // The ONE needs source: the rail speaks the
                                  // same fleet aggregate the rule does.
                                  worldNeeds: railNeeds,
                                  // The bench remembers per world (open slate,
                                  // projection, altitude) across remounts.
                                  worldKey: worldKey,
                                  worldBand: AttachSceneBand(
                                    trace: _visibleTrace,
                                    // Restore the remembered altitude as the
                                    // camera seed — the bench reopens where
                                    // it was left.
                                    initialDistance:
                                        WorkbenchMemory.seedDistance(
                                          WorkbenchMemory.stateOf(
                                            worldKey,
                                          )?.tier,
                                        ),
                                    scenePalette: night
                                        ? ScenePalette.night
                                        : ScenePalette.day,
                                    selected: (final actorId) =>
                                        _selection.value == actorId,
                                    altitude: _altitude,
                                    altitudeOverride: _altitudeOverride,
                                    // VOSGES pick grammar (the canvas answers
                                    // the hand): tap = select/release; hold =
                                    // select AND summon the intent palette
                                    // pre-filtered to that actor.
                                    onTapActor: (final actorId) =>
                                        _selection.value =
                                            _selection.value == actorId
                                            ? null
                                            : actorId,
                                    onHoldActor: (final actorId) {
                                      _selection.value = actorId;
                                      setState(() {
                                        _paletteSeed = actorId;
                                        _paletteOpen = true;
                                      });
                                    },
                                  ),
                                  showScene: widget.showScene,
                                );
                              },
                            ),
                    ),
                    // S4 — the palette floats over the canvas, the ONE verb
                    // grammar for humans and agents alike. Anchored BELOW the
                    // canvas chips (right: 8 / top: 88 — never covering the
                    // altitude chip, audit 3 de-overlap) and never reaching
                    // the Answer Rail's column (width bounded by the canvas,
                    // gate shot 06: the rail card overlapped the palette's
                    // top-left corner).
                    if (_paletteOpen)
                      Positioned(
                        right: 8,
                        top: 88,
                        child: Builder(
                          builder: (final context) {
                            final night =
                                Theme.of(context).brightness == Brightness.dark;
                            return CommandPalette(
                              commands: _commands(sessions),
                              onRun: _runCommand,
                              theme: night
                                  ? InspectorTheme.night
                                  : InspectorTheme.day,
                              initialQuery: _paletteSeed ?? '',
                              width: paletteWidth,
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _expandedCanvas({required Widget child}) =>
      widget.expandedHeight.isInfinite
      ? Expanded(key: const Key('world_inspector.pane'), child: child)
      : SizedBox(
          key: const Key('world_inspector.pane'),
          height: widget.expandedHeight,
          child: child,
        );

  String? _keyOf(final SessionHandle handle) {
    for (final entry in _registry.sessions.entries) {
      if (identical(entry.value, handle)) return entry.key;
    }
    return null;
  }
}

/// One session of the status rule, as data — the same fields the
/// `world_inspector_state` verb reports (equal readers, no widget scrape).
final class WorldInspectorSession {
  const WorldInspectorSession({
    required this.id,
    required this.kind,
    required this.running,
    required this.beats,
    required this.verdict,
    required this.spend,
    required this.pendingPermission,
    this.pendingPermissionSince,
  });

  factory WorldInspectorSession.of(
    final SessionHandle handle, {
    required final String? keyOf,
  }) {
    final state = handle.state;
    final spend = state.spend ?? spendFromVerdict(state.verdict);
    return WorldInspectorSession(
      id: keyOf ?? state.sessionId,
      kind: state.kind,
      running: state.running,
      beats: state.beats.length,
      verdict: state.verdict,
      spend: spend == null
          ? null
          : 'd${spend.decisions} r${spend.rounds} '
                '${spend.tokens}tok ${spend.wallMs}ms',
      pendingPermission: state.pendingPermissionTitle,
      pendingPermissionSince: state.pendingPermissionSince,
    );
  }

  final String id;
  final String kind;
  final bool running;
  final int beats;
  final String? verdict;
  final String? spend;
  final String? pendingPermission;

  /// When the permission opened — the rule's "waiting 4m" reads it
  /// (ADR 0064's clock law; null renders nothing).
  final DateTime? pendingPermissionSince;

  String? get waiting {
    final since = pendingPermissionSince;
    if (since == null) return null;
    final d = DateTime.now().toUtc().difference(since);
    if (d.isNegative) return null;
    if (d.inSeconds < 60) return 'waiting ${d.inSeconds}s';
    if (d.inMinutes < 60) return 'waiting ${d.inMinutes}m';
    return 'waiting ${d.inHours}h';
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'running': running,
    'beats': beats,
    'verdict': ?verdict,
    'spend': ?spend,
    'pendingPermission': ?pendingPermission,
    'pendingPermissionSince': ?pendingPermissionSince?.toIso8601String(),
  };
}

/// One fleet-level attention need on the status rule — the Answer Rail's
/// top tier as data (the `world_inspector_state` verb reports it, so
/// agents read the same "what needs you" the human sees).
final class WorldInspectorNeed {
  const WorldInspectorNeed({
    required this.severity,
    required this.title,
    this.actorId,
  });

  /// `permission` (asks before it acts) or `failed` (a verdict named a
  /// failure). Permission ranks first.
  final String severity;
  final String title;

  /// The actor the need names — tap-to-act (the rule opens the canvas
  /// aligned on it) and the rail's selection alignment ride it.
  final String? actorId;

  int get rank => severity == 'permission' ? 0 : 1;

  Map<String, Object?> toJson() => {
    'severity': severity,
    'title': title,
    'actorId': ?actorId,
  };
}

/// The pane's headless projection (the `world_inspector_state` payload):
/// what the rule shows, what the bands sampled — never a widget scrape.
final class WorldInspectorProjection {
  const WorldInspectorProjection({
    required this.sessions,
    required this.sampledRows,
    required this.sampledSession,
    required this.expanded,
    this.needs = const [],
    this.sampleError,
  });

  final List<WorldInspectorSession> sessions;

  /// The ranked attention needs behind the rule (S2); empty → counts form.
  final List<WorldInspectorNeed> needs;
  final int sampledRows;
  final String sampledSession;
  final bool expanded;

  /// The sampler's last failure ([RegistrySource.lastError]) — a frozen
  /// pane names WHY instead of freezing silently.
  final Object? sampleError;

  Map<String, Object?> toJson() => {
    'sessions': [for (final s in sessions) s.toJson()],
    'needs': [for (final n in needs) n.toJson()],
    'sampledRows': sampledRows,
    'sampledSession': sampledSession,
    'expanded': expanded,
    'sampleError': ?sampleError?.toString(),
  };

  String get summary {
    if (sessions.isEmpty) return 'no live sessions';
    final running = sessions.where((final s) => s.running).length;
    final top = needs.isEmpty ? '' : ' — needs you: ${needs.first.title}';
    return '${sessions.length} session(s), $running running, '
        '${needs.length} attention need(s)$top; sampled $sampledRows row(s) '
        'of ${sampledSession.isEmpty ? '—' : sampledSession}';
  }
}

// The doc-grid vocabulary (discipline, not pixels — agent_doc_surface is
// the reference implementation; these are its same constants locally).

TextStyle _label(final ThemeData theme) => theme.textTheme.labelSmall!.copyWith(
  fontSize: 9.5,
  letterSpacing: 1.2,
  color: theme.colorScheme.onSurfaceVariant,
  fontFeatures: const [FontFeature.tabularFigures()],
);

TextStyle _mono(final ThemeData theme, {final Color? color}) =>
    theme.textTheme.bodySmall!.copyWith(
      fontFamily: 'Menlo',
      fontFamilyFallback: const ['monospace'],
      fontSize: 11,
      height: 1.45,
      color: color ?? theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
