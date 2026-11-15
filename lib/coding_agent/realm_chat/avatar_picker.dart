/// Wave N2 — the avatar picker: the channel-icon law applied to
/// actors. ONE dialog: the curated glyph grid ([kActorAvatarGlyphs]),
/// one free emoji/character field, and a clear verb. Returns null on
/// cancel, `''` on clear, else the chosen mark — the caller owns the
/// write (the editor composes it into the save verb).
library;

import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/common_imports.dart';

/// The avatar dialog: glyph grid + custom field + clear/confirm.
Future<String?> pickActorAvatar(
  final BuildContext context, {
  final String? current,
}) => showDialog<String?>(
  context: context,
  builder: (final dialogContext) => _AvatarDialog(
    initial: current ?? '',
    l10n: dialogContext.l10n,
  ),
);

final class _AvatarDialog extends StatefulWidget {
  const _AvatarDialog({required this.initial, required this.l10n});

  final String initial;
  final S l10n;

  @override
  State<_AvatarDialog> createState() => _AvatarDialogState();
}

final class _AvatarDialogState extends State<_AvatarDialog> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.initial,
  );
  String? _hovered;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _isCustom(final String value) =>
      value.isNotEmpty && !kActorAvatarGlyphs.containsKey(value);

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final value = _ctrl.text;
    return AlertDialog(
      key: const ValueKey('actor.avatar.dialog'),
      title: Text(widget.l10n.actorsAvatar),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final name in kActorAvatarGlyphs.keys)
                  MouseRegion(
                    onEnter: (_) => setState(() => _hovered = name),
                    onExit: (_) => setState(() => _hovered = null),
                    child: GestureDetector(
                      key: ValueKey('actor.avatar.glyph.$name'),
                      onTap: () => setState(() => _ctrl.text = name),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: value == name || _hovered == name
                              ? la.ink.withValues(alpha: 0.08)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          kActorAvatarGlyphs[name],
                          size: 16,
                          color: la.inkMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('actor.avatar.custom'),
              controller: _ctrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: widget.l10n.actorsAvatarHint,
                isDense: true,
              ),
            ),
            if (_isCustom(value))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('actor.avatar.clear'),
          onPressed: () => Navigator.of(context).pop(''),
          child: Text(widget.l10n.actorsAvatarClear),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.l10n.worldChatCancel),
        ),
        TextButton(
          key: const ValueKey('actor.avatar.confirm'),
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          child: Text(widget.l10n.actorsCreate),
        ),
      ],
    );
  }
}
