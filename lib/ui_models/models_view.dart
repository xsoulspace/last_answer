/// Models refactor (2026-11-14, owner-approved design doc
/// docs/design/models-management-refactor-2026-11-14.md) — the Models
/// surface as THREE LENSES over ONE palette document, in the hierarchy
/// the owner asked for (providers first, then models), with the
/// spreadsheet law: nested rows, verbs on the row that owns them, and a
/// compact row shape below 640px so the same tree reads on a phone.
///
/// * CATALOG — the provider → model nested table, the inline edit
///   forms (full per-model schema), and the raw JSON lane;
/// * BINDINGS — the editable cast ladder (order, persisted primary,
///   session override chip, actor chips);
/// * OBSERVE — daemon controls, the per-rung health ledger (cooldowns
///   and named skips visible, verbatim) and the per-model dispatch
///   ledger.
///
/// The gate honesty law (owner decision D1): NO tier gate on the
/// surface. Reading is free, drafting and Propose are free for every
/// seat, and the ONE real authority gate is the harness's owner-only
/// `palette_apply`, whose refusal + recovery render verbatim in the
/// dirty bar. The retired `ProviderEditorDialog`'s Pro-gated entry was
/// a second gate stacked on top of that one.
///
/// This State owns the single [PaletteCandidateModel] every lens edits,
/// re-based off the live read model whenever the world notifies (a
/// clean candidate adopts the new truth; a dirty one keeps its edits).
library;

import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_models/catalog_lens.dart';
import 'package:lastanswer/ui_models/local_models_state.dart';
import 'package:lastanswer/ui_models/models_widgets.dart';
import 'package:lastanswer/ui_models/package_local_model_runtime.dart';
import 'package:lastanswer/ui_models/palette_candidate.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';

/// The compact breakpoint: below it the rows drop their secondary chip
/// run and subtitles (identity + count + chevron), and the facts move
/// into the expanded block — one tree, three form factors.
const double kModelsCompactWidth = 640;

/// The realm chat service's palette verbs as the candidate's lane.
final class _ServicePaletteLane implements PaletteVerbLane {
  const _ServicePaletteLane(this.service);

  final RealmChatService service;

  @override
  Future<Map<String, Object?>> propose(final Map<String, Object?> candidate) =>
      service.proposePalette(candidate);

  @override
  Future<Map<String, Object?>> apply(
    final Map<String, Object?> candidate, {
    final String? expectedBeforeSha256,
  }) => service.applyPalette(
    candidate,
    expectedBeforeSha256: expectedBeforeSha256,
  );
}

final class ModelsView extends StatefulWidget {
  const ModelsView({
    required this.world,
    this.service,
    this.localModels,
    super.key,
  });

  final WorldStateService world;

  /// The realm chat service the palette verbs ride. Injected by tests;
  /// in the shell it resolves from the provider scope. Null degrades
  /// honestly: the dirty bar names the missing seat.
  final RealmChatService? service;

  /// The local model manager's state (the catalog lens's "Local model
  /// catalog" section). Injected by tests (a fake installer, no
  /// network); when null the view creates its own over the package
  /// installer and owns its lifecycle.
  final LocalModelsState? localModels;

  @override
  State<ModelsView> createState() => _ModelsViewState();
}

final class _ModelsViewState extends State<ModelsView> {
  PaletteCandidateModel? _model;
  LocalModelsState? _ownedLocalModels;
  bool _restartPending = false;
  int? _pidAtPending;

  RealmChatService? get _service =>
      widget.service ?? context.read<RealmChatService?>();

  /// The injected state is NOT owned here; the self-made one is.
  LocalModelsState get _localModels => widget.localModels ?? _ownedLocalModels!;

  @override
  void initState() {
    super.initState();
    widget.world.addListener(_sync);
    if (widget.localModels == null) {
      _ownedLocalModels = LocalModelsState(
        // The runtime is the second lifecycle stage (Download vs Load):
        // with it the rows carry Load/Unload; production always rides
        // the package runtime — the dylib itself is the registry, so a
        // preloaded model is the SAME engine the chat lanes adopt.
        runtime: PackageLocalModelRuntime(),
      );
      // The initial state probe (the installer answers per entry;
      // the stub answers synchronously, the real installer reads the
      // hub cache — off the ticker either way).
      unawaited(_ownedLocalModels!.refresh());
    }
    // The pane-visible budget cadence (2026-11-18 v3 realtime law):
    // the bar re-senses while this pane lives — memory is exactly the
    // fact that changes UNDER a live model. The state no-ops the
    // poller in the test lane (no hidden timers there).
    _localModels.startBudgetPolling();
    _sync();
  }

  @override
  void dispose() {
    widget.world.removeListener(_sync);
    _localModels.stopBudgetPolling();
    final model = _model;
    if (model != null) {
      model
        ..removeListener(_onModelChanged)
        ..dispose();
    }
    _ownedLocalModels?.dispose();
    super.dispose();
  }

  /// The config-root dialog (the owner's v3.2 option): an empty field
  /// returns to the defaults (the daemon's realm root, else the global
  /// `~/.xsoulspace`); a path pins the palette read to that root —
  /// persisted across runs, never a guessed location (the service
  /// re-reads and the header shows the ACTIVE path verbatim).
  Future<void> _askConfigRoot(final BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: widget.world.configRootOverride ?? '',
    );
    final saved = await showLaDialog<bool>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        titleText: l10n.modelsConfigRootTitle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.modelsConfigRootHint,
              style: dialogContext.laUi.micro.copyWith(
                fontSize: 11,
                color: dialogContext.la.inkMuted,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 420,
              child: LaField(
                key: const ValueKey('models.config.field'),
                controller: controller,
                placeholder: '~/.xsoulspace',
              ),
            ),
          ],
        ),
        actions: [
          LaButton(
            key: const ValueKey('models.config.cancel'),
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            label: l10n.modelsCancel,
          ),
          LaButton(
            key: const ValueKey('models.config.save'),
            variant: LaButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: l10n.modelsConfigRootSave,
          ),
        ],
      ),
    );
    if (saved == true) {
      widget.world.configRootOverride = controller.text;
    }
    controller.dispose();
  }

  Map<String, Object?> _liveWire() {
    final palette = widget.world.palette;
    if (palette != null) return paletteWireDocument(palette);
    return <String, Object?>{
      'providers': <String, Object?>{},
      'cast': <Object?>[],
    };
  }

  /// The world moved: re-base the candidate (clean adopts, dirty keeps
  /// its edits), and retire the restart-pending banner once the daemon
  /// actually restarts (a new pid is the evidence). The first call runs
  /// inside initState, so the candidate is assigned WITHOUT setState —
  /// the initial build reads it directly.
  void _sync() {
    final wire = _liveWire();
    final model = _model;
    if (model == null) {
      _model = PaletteCandidateModel(
        live: wire,
        lane: _service == null ? null : _ServicePaletteLane(_service!),
      )..addListener(_onModelChanged);
      return;
    }
    model.rebase(wire);
    if (_restartPending && widget.world.daemonPid != _pidAtPending) {
      setState(() => _restartPending = false);
    }
  }

  /// The candidate moved: an apply that landed a restart-required
  /// revision arms the banner (off the model's own notification, never
  /// as a builder side effect); the banner rides until the daemon's
  /// pid changes (the restart's own evidence) or the owner restarts
  /// from the daemon strip.
  void _onModelChanged() {
    final outcome = _model?.applyOutcome;
    if (outcome == null || outcome['ok'] != true) return;
    if (outcome['restartRequired'] != true || _restartPending) return;
    if (!mounted) return;
    setState(() {
      _restartPending = true;
      _pidAtPending = widget.world.daemonPid;
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    final compact = MediaQuery.sizeOf(context).width < kModelsCompactWidth;
    final model = _model;
    return ListenableBuilder(
      listenable: model ?? widget.world,
      builder: (final context, final _) => Column(
        key: const ValueKey('shell.modelsView'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // The lens switcher is GONE (2026-11-19, the merge
                    // law): one Models surface — the ladder (priority,
                    // health, cache) + the providers' config beneath it.
                    if (widget.world.paletteConfigPath case final path?)
                      Flexible(
                        child: Text(
                          path,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LaTokens.mono(9, la.inkQuiet),
                        ),
                      ),
                    // The config-root option (2026-11-18 v3.2, the
                    // owner's law): the active path is shown where it
                    // matters AND is editable — Last Answer must never
                    // silently point at a development checkout.
                    ModelsButton(
                      keyName: 'models.config.edit',
                      label: l10n.modelsConfigRootEdit,
                      onTap: () => unawaited(_askConfigRoot(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // The daemon strip (the Observe absorption): the world
                // process's facts + verbs, above every lens.
                _DaemonStrip(world: widget.world),
                const SizedBox(height: 8),
                if (widget.world.paletteAbsence case final refusal?)
                  ModelsRefusalNote(
                    keyName: 'models.palette.refusal',
                    text: refusal,
                  )
                else if (widget.world.palette == null)
                  ModelsRefusalNote(
                    keyName: 'models.palette.empty',
                    text: widget.world.paletteConfigPath == null
                        ? l10n.modelsNoPalette
                        : '${l10n.modelsNoPalette} · '
                              '${widget.world.paletteConfigPath}',
                  ),
                if (_restartPending)
                  Container(
                    key: const ValueKey('models.restartPending'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: la.caution.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(ShellTokens.radius),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.modelsRestartPending,
                            style: LaTokens.mono(10, la.inkMuted),
                          ),
                        ),
                        ModelsButton(
                          keyName: 'models.restartPending.restart',
                          label: l10n.modelsRestartNow,
                          onTap: () => unawaited(widget.world.restartWorld()),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: model == null
                  ? const SizedBox.shrink()
                  : CatalogLens(
                      model: model,
                      world: widget.world,
                      compact: compact,
                      localModels: _localModels,
                      service: _service,
                    ),
            ),
          ),
          if (model != null &&
              (model.dirty ||
                  model.refusal != null ||
                  model.receipt != null ||
                  model.applyOutcome != null))
            PaletteDirtyBar(model: model),
        ],
      ),
    );
  }
}

/// The daemon strip (2026-11-19, the Observe absorption): the world
/// process's facts + verbs as ONE slim header row — live/pid, the
/// scheduler leg, and Restart/Stop (or Arm when down). It sits above
/// every lens because it is about the daemon, not about a model.
final class _DaemonStrip extends StatelessWidget {
  const _DaemonStrip({required this.world});

  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final l10n = context.l10n;
    return Container(
      key: const ValueKey('models.daemonStrip'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.shellRaised,
        borderRadius: BorderRadius.circular(ShellTokens.radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  world.daemonLive
                      ? world.daemonPid == null
                            ? l10n.modelsDaemonLive
                            : '${l10n.modelsDaemonLive} · '
                                  'pid ${world.daemonPid}'
                      : l10n.modelsDaemonDown,
                  key: const ValueKey('models.daemon'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.compact.copyWith(
                    color: world.daemonLive ? null : la.caution,
                    fontSize: 12,
                  ),
                ),
                Text(
                  world.schedulerLive
                      ? world.schedulerPid == null
                            ? l10n.modelsSchedulerLive
                            : '${l10n.modelsSchedulerLive} · '
                                  'pid ${world.schedulerPid}'
                      : l10n.modelsSchedulerDown,
                  key: const ValueKey('models.scheduler'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.micro.copyWith(
                    color: world.schedulerLive ? la.inkQuiet : la.caution,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            // A narrow split pane scales the verb cluster as a whole
            // instead of overflowing (the daemon-cluster law).
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!world.daemonLive)
                    ModelsButton(
                      keyName: 'models.arm',
                      label: world.armState == WorldArmState.arming
                          ? l10n.edgeArming
                          : l10n.edgeArmWorld,
                      busy: world.armState == WorldArmState.arming,
                      onTap: () => unawaited(world.armWorld()),
                    )
                  else ...[
                    ModelsButton(
                      keyName: 'models.restart',
                      label: l10n.edgeRestartWorld,
                      onTap: () => unawaited(world.restartWorld()),
                    ),
                    const SizedBox(width: 6),
                    ModelsButton(
                      keyName: 'models.stop',
                      label: l10n.edgeStopWorld,
                      onTap: () => unawaited(world.stopWorld()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
