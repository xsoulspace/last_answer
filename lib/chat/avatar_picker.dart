/// Wave N2 — the avatar picker: the channel-icon law applied to
/// actors. ONE dialog: the curated glyph grid ([kActorAvatarGlyphs]),
/// one free emoji/character field, and a clear verb. Returns null on
/// cancel, `''` on clear, else the chosen mark — the caller owns the
/// write (the editor composes it into the save verb).
library;

import 'package:lastanswer/chat/actor_avatar.dart';
import 'package:lastanswer/common_imports.dart';

/// The avatar dialog: glyph grid + custom field + clear/confirm.
Future<String?> pickActorAvatar(
  final BuildContext context, {
  final String? current,
}) => showLaDialog<String?>(
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

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _isCustom(final String value) =>
      value.isNotEmpty && !kActorAvatarGlyphs.containsKey(value);

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final value = _ctrl.text;
    return LaDialog(
      key: const ValueKey('actor.avatar.dialog'),
      showClose: false,
      titleText: widget.l10n.actorsAvatar,
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
                  LaPressable(
                    key: ValueKey('actor.avatar.glyph.$name'),
                    onTap: () => setState(() => _ctrl.text = name),
                    selected: value == name,
                    radius: BorderRadius.circular(8),
                    padding: const EdgeInsets.all(9),
                    child: Icon(
                      kActorAvatarGlyphs[name],
                      size: 16,
                      color: laUi.inkMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            LaField(
              key: const ValueKey('actor.avatar.custom'),
              controller: _ctrl,
              onChanged: (_) => setState(() {}),
              placeholder: widget.l10n.actorsAvatarHint,
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
        LaButton(
          key: const ValueKey('actor.avatar.clear'),
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(''),
          label: widget.l10n.actorsAvatarClear,
        ),
        LaButton(
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
          label: widget.l10n.worldChatCancel,
        ),
        LaButton(
          key: const ValueKey('actor.avatar.confirm'),
          variant: LaButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          label: widget.l10n.actorsCreate,
        ),
      ],
    );
  }
}
