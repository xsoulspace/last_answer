/// ADR 0119 — the brain's daemon-side health verdict as one small dot,
/// shared by every brain picker and profile surface (1b: the brain is
/// a RESOURCE — its health travels with its name wherever it is
/// offered). Green `ok`, grey `unknown`, amber
/// `not_downloaded`/`downloading`/`loading`, red `failed`. The tooltip
/// names the code and the daemon's fix hint; a brain the palette
/// doesn't name (a local brain, a stale file) renders nothing at all —
/// no verdict, no chrome.
library;

import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';

final class BrainHealthDot extends StatelessWidget {
  const BrainHealthDot({required this.brainRef, super.key});

  final String brainRef;

  static final PaletteHealthStore _store = PaletteHealthStore();

  @override
  Widget build(final BuildContext context) {
    final health = _store.statusFor(brainRef);
    if (health == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final color = switch (health.status) {
      'ok' => const Color(0xFF30A46C),
      'failed' => theme.colorScheme.error,
      'unknown' => context.shellMuted,
      _ => const Color(0xFFB58A00),
    };
    return Tooltip(
      message:
          '${health.status}'
          '${health.code == null ? '' : ' (${health.code})'}'
          '${health.detail == null ? '' : ' — ${health.detail}'}',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
