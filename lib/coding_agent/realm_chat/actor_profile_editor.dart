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
    super.key,
  });

  /// The identity being edited — the fields seed from it.
  final ActorProfile profile;

  /// The brain picker's options (the runtime's [availableBrainOptions]).
  final List<({String ref, String label})> brainOptions;

  /// Applied on Save: the trimmed name/role, the persona VERBATIM (the
  /// actor speaks through it) and the rebuilt brainRef.
  final void Function({
    required String displayName,
    required String role,
    required String systemPrompt,
    required String brainRef,
  })
  onSave;

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
        ? buildLocalBrainRef(parsed.cast)
        : (widget.profile.brainRef.isEmpty
              ? null
              : brainRefBase(widget.profile.brainRef));
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
    final String brainRef;
    if (base == null || base.isEmpty) {
      brainRef = widget.profile.brainRef; // no brain picked: no change
    } else if (_isLocalBinding) {
      brainRef = buildLocalBrainRef(
        base.substring('local:'.length),
        temperature: double.tryParse(_temperature.text.trim()),
        repetitionPenalty: double.tryParse(_repetition.text.trim()),
      );
    } else {
      brainRef = base;
    }
    widget.onSave(
      displayName: _name.text.trim(),
      role: _role.text.trim(),
      systemPrompt: _persona.text,
      brainRef: brainRef,
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
                child: Text(option.label, overflow: TextOverflow.ellipsis),
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
