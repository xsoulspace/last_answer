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

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/bindings_lens.dart';
import 'package:lastanswer/shell/models/catalog_lens.dart';
import 'package:lastanswer/shell/models/models_widgets.dart';
import 'package:lastanswer/shell/models/observe_lens.dart';
import 'package:lastanswer/shell/models/palette_candidate.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// The compact breakpoint: below it the rows drop their secondary chip
/// run and subtitles (identity + count + chevron), and the facts move
/// into the expanded block — one tree, three form factors.
const double kModelsCompactWidth = 640;

enum ModelsLens { catalog, bindings, observe }

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
  const ModelsView({required this.world, this.service, super.key});

  final WorldStateService world;

  /// The realm chat service the palette verbs ride. Injected by tests;
  /// in the shell it resolves from the provider scope. Null degrades
  /// honestly: the dirty bar names the missing seat.
  final RealmChatService? service;

  @override
  State<ModelsView> createState() => _ModelsViewState();
}

final class _ModelsViewState extends State<ModelsView> {
  ModelsLens _lens = ModelsLens.catalog;
  PaletteCandidateModel? _model;
  bool _restartPending = false;
  int? _pidAtPending;

  RealmChatService? get _service =>
      widget.service ?? context.read<RealmChatService?>();

  @override
  void initState() {
    super.initState();
    widget.world.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    widget.world.removeListener(_sync);
    final model = _model;
    if (model != null) {
      model
        ..removeListener(_onModelChanged)
        ..dispose();
    }
    super.dispose();
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
  /// from the Observe lens.
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
                      // A narrow split pane wraps the switcher instead
                      // of overflowing it (a RenderFlex overflow is an
                      // error, never a layout).
                      Flexible(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final lens in ModelsLens.values)
                              _LensButton(
                                lens: lens,
                                selected: _lens == lens,
                                label: switch (lens) {
                                  ModelsLens.catalog => l10n.modelsLensCatalog,
                                  ModelsLens.bindings =>
                                    l10n.modelsLensBindings,
                                  ModelsLens.observe => l10n.modelsLensObserve,
                                },
                                onTap: () => setState(() => _lens = lens),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (widget.world.paletteConfigPath case final path?)
                        Flexible(
                          child: Text(
                            path,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LaTokens.mono(9, la.inkQuiet),
                          ),
                        ),
                    ],
                  ),
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
                    : switch (_lens) {
                        ModelsLens.catalog => CatalogLens(
                          model: model,
                          world: widget.world,
                          compact: compact,
                        ),
                        ModelsLens.bindings => BindingsLens(
                          model: model,
                          world: widget.world,
                          compact: compact,
                          service: _service,
                        ),
                        ModelsLens.observe => ObserveLens(
                          world: widget.world,
                          compact: compact,
                          service: _service,
                        ),
                      },
              ),
            ),
            if (model != null &&
                _lens != ModelsLens.observe &&
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

/// The lens switcher's segmented button: one height, the selected lens
/// rides the raised fill (the ONE-shadow law's flat-at-rest family).
final class _LensButton extends StatelessWidget {
  const _LensButton({
    required this.lens,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final ModelsLens lens;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      button: true,
      selected: selected,
      label: 'models.lens.${lens.name}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: ValueKey('models.lens.${lens.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: selected
                  ? la.ink.withValues(alpha: 0.10)
                  : la.ink.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            // Padding, NOT Center/alignment: both expand to the
            // incoming max width under bounded-loose constraints (the
            // Wrap), stretching every pill to the pane (live-caught
            // via the widget inspector, 2026-11-15).
            child: Text(
              label,
              style: context.laUi.micro?.copyWith(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : null,
                color: selected ? la.ink : la.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
