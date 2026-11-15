/// ADR 0023 §1a — THE one actor-identity editor, embedded by both edit
/// surfaces: the context column's actor panel (PEOPLE tab, focused
/// actor) and the Settings actors pane's inline row expansion. Inline
/// fields, one Save — no modals anywhere (DESIGN §6: the human edits in
/// place, the surface never blocks).
///
/// Fields: name, role, persona prompt, brain (from
/// [availableBrainOptions]) and — for `local:` bindings — the sampling
/// overrides the grammar parses (`temperature`, `repetitionPenalty`,
/// built back into the brainRef query string by [buildLocalBrainRef];
/// `actor_brain.dart` is read-only there). Save hands the new values to
/// the caller, which routes them through `RealmChatService.updateActor`
/// — the persistence and the loop rebuild live there, not here.
library;

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/avatar_picker.dart';
import 'package:lastanswer/coding_agent/realm_chat/brain_health_dot.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/common_imports.dart';

/// The editor's agent-contract widget keys (DESIGN §6) — shared by both
/// surfaces, so intents target the same fields wherever they render.
const actorEditorNameKey = 'actor.edit.name';
const actorEditorRoleKey = 'actor.edit.role';
const actorEditorPersonaKey = 'actor.edit.persona';
const actorEditorBrainKey = 'actor.edit.brain';
const actorEditorTemperatureKey = 'actor.edit.temperature';
const actorEditorRepetitionKey = 'actor.edit.repetitionPenalty';
const actorEditorSaveKey = 'actor.edit.save';
const actorEditorCancelKey = 'actor.edit.cancel';

/// One actor's inline edit form (name, role, persona, brain, sampling).
final class ActorProfileEditor extends StatefulWidget {
  const ActorProfileEditor({
    required this.profile,
    required this.brainOptions,
    required this.onSave,
    this.onCancel,
    this.saveKey,
    this.tiersForBrain,
    super.key,
  });

  /// The identity being edited — the fields seed from it.
  final ActorProfile profile;

  /// The brain picker's options (the runtime's [availableBrainOptions]).
  final List<({String ref, String label})> brainOptions;

  /// Applied on Save: the trimmed name/role, the persona VERBATIM (the
  /// actor speaks through it), the rebuilt brainRef (the per-actor
  /// reasoning level rides its grammar) and the avatar mark (null =
  /// untouched, `''` = cleared back to the derived identity).
  final void Function({
    required String displayName,
    required String role,
    required String systemPrompt,
    required String brainRef,
    required String? avatar,
  })
  onSave;

  /// The reasoning tiers the SELECTED brain's lane declares (the Zed
  /// capability law); null hides the reasoning block entirely (hosts
  /// without a palette read model).
  final List<String> Function(String brainRef)? tiersForBrain;

  /// The surface owns the edit mode; Cancel hands the decision back.
  final VoidCallback? onCancel;

  /// Overrides the save button's contract key (a surface may need to
  /// disambiguate); defaults to [actorEditorSaveKey].
  final Key? saveKey;

  @override
  State<ActorProfileEditor> createState() => _ActorProfileEditorState();
}

class _ActorProfileEditorState extends State<ActorProfileEditor> {
  // Deliberately non-final: a re-seed (Cancel, an edited profile landing)
  // replaces the controllers, disposing the previous ones first.
  late TextEditingController _name;
  late TextEditingController _role;
  late TextEditingController _persona;
  late TextEditingController _temperature;
  late TextEditingController _repetition;
  late String? _brainBase;
  late String? _avatar;
  late String? _reasoning;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(final ActorProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) _seed();
  }

  void _seed() {
    final parsed = parseLocalBrainRef(widget.profile.brainRef);
    if (_seeded) {
      // A re-seed (Cancel, a changed profile landing): the replaced
      // controllers must not leak.
      _name.dispose();
      _role.dispose();
      _persona.dispose();
      _temperature.dispose();
      _repetition.dispose();
    }
    _seeded = true;
    _name = TextEditingController(text: widget.profile.displayName);
    _role = TextEditingController(text: widget.profile.role);
    _persona = TextEditingController(text: widget.profile.systemPrompt);
    _temperature = TextEditingController(
      text: parsed?.temperature?.toString() ?? '',
    );
    _repetition = TextEditingController(
      text: parsed?.repetitionPenalty?.toString() ?? '',
    );
    _brainBase = parsed != null
        ? buildLocalBrainRef(
            parsed.cast,
            // The seed carries EVERY parsed param: a temperature-only
            // save must not drop the lora binding (wave N2).
            lora: parsed.lora,
            loraScale: parsed.loraScale,
          )
        : (widget.profile.brainRef.isEmpty
              ? null
              : brainRefBase(widget.profile.brainRef));
    _avatar = widget.profile.avatar;
    _reasoning = brainParam(widget.profile.brainRef, 'reasoning');
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _persona.dispose();
    _temperature.dispose();
    _repetition.dispose();
    super.dispose();
  }

  bool get _isLocalBinding => (_brainBase ?? '').startsWith('local:');

  void _save() {
    final base = _brainBase;
    String brainRef;
    if (base == null || base.isEmpty) {
      brainRef = widget.profile.brainRef; // no brain picked: no change
    } else if (_isLocalBinding) {
      final parsed = parseLocalBrainRef(base);
      brainRef = buildLocalBrainRef(
        base.substring('local:'.length),
        temperature: double.tryParse(_temperature.text.trim()),
        repetitionPenalty: double.tryParse(_repetition.text.trim()),
        lora: parsed?.lora,
        loraScale: parsed?.loraScale,
      );
    } else {
      brainRef = base;
    }
    // The per-actor reasoning level rides the grammar on ANY base
    // (wave N2): null removes the param, the declaration's default
    // returns.
    brainRef = withBrainParam(brainRef, 'reasoning', _reasoning);
    widget.onSave(
      displayName: _name.text.trim(),
      role: _role.text.trim(),
      systemPrompt: _persona.text,
      brainRef: brainRef,
      avatar: _avatar,
    );
  }

  void _cancel() {
    _seed();
    widget.onCancel?.call();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // A binding that predates the picker's options (or a hosted model
    // the option list lost) must still render — the raw ref stands in.
    final options = [
      for (final option in widget.brainOptions) option,
      if (_brainBase != null &&
          _brainBase!.isNotEmpty &&
          !widget.brainOptions.any((option) => option.ref == _brainBase))
        (ref: _brainBase!, label: _brainBase!),
    ];
    return Column(
      key: const ValueKey('actor.edit'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey(actorEditorNameKey),
          controller: _name,
          decoration: InputDecoration(
            labelText: l10n.actorsNameLabel,
            hintText: l10n.actorsNameHint,
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey(actorEditorRoleKey),
          controller: _role,
          decoration: InputDecoration(
            labelText: l10n.actorsRoleLabel,
            hintText: l10n.actorsRoleHint,
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey(actorEditorPersonaKey),
          controller: _persona,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: l10n.actorsPersonaLabel,
            hintText: l10n.actorsPersonaHint,
            alignLabelWithHint: true,
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: const ValueKey(actorEditorBrainKey),
          initialValue: _brainBase,
          // The panel is narrow (240px): the selected label must shrink,
          // never overflow the field.
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.actorsBrainLabel,
            isDense: true,
          ),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option.ref,
                // 1b — the brain's health verdict rides its name here
                // too (the resource law travels with the picker).
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    BrainHealthDot(brainRef: option.ref),
                  ],
                ),
              ),
          ],
          onChanged: (final value) => setState(() => _brainBase = value),
        ),
        if (_isLocalBinding) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey(actorEditorTemperatureKey),
                  controller: _temperature,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.actorsTemperatureLabel,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const ValueKey(actorEditorRepetitionKey),
                  controller: _repetition,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.actorsRepetitionLabel,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.actorsSamplingHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        // Wave N2 — the owner-set mark: the picker dialog (the
        // channel-icon law), the current mark previewed beside it.
        Row(
          children: [
            TextButton(
              key: const ValueKey('actor.edit.avatar'),
              onPressed: () async {
                final picked = await pickActorAvatar(
                  context,
                  current: _avatar,
                );
                if (picked != null) setState(() => _avatar = picked);
              },
              child: Text(l10n.actorsAvatar),
            ),
            const SizedBox(width: 8),
            if (_avatar != null && _avatar!.isNotEmpty)
              Text(_avatar!, style: const TextStyle(fontSize: 18)),
          ],
        ),
        if (widget.tiersForBrain case final tiersFor?) ...[
          const SizedBox(height: 8),
          Text(l10n.actorsReasoning, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          if (tiersFor(_brainBase ?? '').isEmpty)
            Text(
              l10n.actorsReasoningNoLane,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tier in <String>{
                  ...tiersFor(_brainBase ?? ''),
                  ?_reasoning,
                })
                  TextButton(
                    key: ValueKey('actor.edit.reasoning.$tier'),
                    onPressed: () => setState(
                      () => _reasoning = _reasoning == tier ? null : tier,
                    ),
                    child: Text(
                      _reasoning == tier
                          ? '✓ ${reasoningEffortTitle(tier)}'
                          : reasoningEffortTitle(tier),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.actorsReasoningDaemonNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
        const SizedBox(height: 8),
        // The panel is narrow: the pair WRAPS instead of overflowing.
        OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: 8,
          overflowSpacing: 8,
          children: [
            if (widget.onCancel != null)
              TextButton(
                key: const ValueKey(actorEditorCancelKey),
                onPressed: _cancel,
                child: Text(l10n.actorsDiscardChanges),
              ),
            FilledButton(
              key: widget.saveKey ?? const ValueKey(actorEditorSaveKey),
              onPressed: _name.text.trim().isEmpty ? null : _save,
              child: Text(l10n.actorsSaveChanges),
            ),
          ],
        ),
      ],
    );
  }
}
