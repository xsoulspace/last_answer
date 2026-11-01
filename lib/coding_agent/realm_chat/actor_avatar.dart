/// ADR 0007 — the actor avatar: deterministic identity at a glance, the
/// visual backbone of the actor rail (Grok/Discord style: every actor
/// is an avatar with a kind badge and a presence dot).
///
/// The identicon is a pure function of `actorId`: an FNV-1a hash picks
/// the hue and one of N blob/glyph shapes. The same actor renders the
/// same avatar on every device and session — no assets, no network, no
/// per-platform drift. Humans render a distinct initials monogram;
/// models and agents render the blob+glyph. Presence stays OUT of the
/// widget: it arrives as [ActorAvatar.presenceOnline], folded from
/// `RealmBotHost.statuses` / `realm_actors.lastSeenAt` by the caller
/// (ADR 0007 §2).
///
/// Widget keys are the agent's UI contract (DESIGN §6): the avatar
/// marks its identity `ValueKey('actor.avatar.<actorId>')` and its
/// presence dot `ValueKey('actor.presence.<actorId>')` — independent of
/// any caller-supplied widget key.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_presence.dart';

/// FNV-1a, 32-bit — NOT [String.hashCode], which Dart randomizes per
/// process; identity must be byte-stable across devices and sessions.
int _fnv1a(final String s) {
  var h = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

/// One actor's visual identity, hashed apart per dimension so they
/// never correlate: hue from the bare id (golden-angle stepped, so even
/// near-identical ids land in different hues), shape family, rotation
/// and layout jitter from salted rehashes of the same id.
typedef ActorIdentity = ({
  double hue,
  int variant,
  double rotationDeg,
  int bitsA,
  int bitsB,
});

const int _variantCount = 6;

const double _hueSaturation = 0.45;
const double _hueLightness = 0.36;

ActorIdentity _identityFor(final String actorId) {
  final h = _fnv1a(actorId);
  final hs = _fnv1a('$actorId\u0000shape');
  return (
    hue: (h * 137.508) % 360,
    variant: hs % _variantCount,
    rotationDeg: ((hs >> 5) % 24) * 15.0,
    bitsA: (h >> 8) & 0xFFFF,
    bitsB: (hs >> 9) & 0x7FFF,
  );
}

/// The actor's identity color — a pure function of [actorId]. The rail
/// reuses it for channels, groups and accents, so one actor reads as
/// one hue everywhere it appears. Deep enough for ≥4.5:1 text on light
/// surfaces (the de-Material pass: ink earns color, fills earn tints).
Color actorColor(final String actorId) => HSLColor.fromAHSL(
  1,
  _identityFor(actorId).hue,
  _hueSaturation,
  _hueLightness,
).toColor();

/// The actor's quiet disc fill: the identity hue as a 12% tint over the
/// surface — the mark steps back so the words carry the page
/// (docs/design/shell-de-material-plan.md §2).
Color actorTint(final String actorId) =>
    actorColor(actorId).withValues(alpha: 0.12);

/// The blob+glyph identicon for [actorId] at [size]: a deep tinted disc
/// carrying one deterministic shape family in two tones of the actor's
/// hue. The bot/model mark — and the rail's mark for channels and
/// groups, which need no profile, just the id.
Widget actorIdenticon(final String actorId, {required final double size}) =>
    SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _IdenticonPainter(_identityFor(actorId))),
    );

/// Paints the identicon: deep tinted disc, then the shape family chosen
/// by the hash. Value equality on the derived identity makes repaints
/// honest and lets tests assert determinism by painter comparison.
@immutable
final class _IdenticonPainter extends CustomPainter {
  const _IdenticonPainter(this.identity);

  final ActorIdentity identity;

  @override
  void paint(final Canvas canvas, final Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    // De-Material pass: a 12% tint disc carrying shapes in two tones of
    // the identity INK — the hue reads, the disc no longer shouts.
    final bgPaint = Paint()
      ..color = HSLColor.fromAHSL(
        1,
        identity.hue,
        _hueSaturation,
        _hueLightness,
      ).toColor().withValues(alpha: 0.12);
    final primary = Paint()
      ..color = HSLColor.fromAHSL(
        1,
        identity.hue,
        _hueSaturation,
        _hueLightness,
      ).toColor();
    final secondary = Paint()
      ..color = HSLColor.fromAHSL(1, identity.hue, 0.30, 0.52).toColor();

    canvas
      ..drawCircle(center, s / 2, bgPaint)
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(identity.rotationDeg * math.pi / 180)
      // The mark steps back: shapes at 66% leave the tinted disc
      // visible around them (de-Material pass §2).
      ..scale(0.66);
    switch (identity.variant) {
      case 0:
        _triad(canvas, s, primary, secondary);
      case 1:
        _diamond(canvas, s, primary, secondary);
      case 2:
        _leaf(canvas, s, primary, secondary);
      case 3:
        _bars(canvas, s, primary, secondary, identity.bitsA, identity.bitsB);
      case 4:
        _ring(canvas, s, primary, secondary);
      case 5:
        _peaks(canvas, s, primary, secondary);
    }
    canvas.restore();
  }

  void _triad(
    final Canvas canvas,
    final double s,
    final Paint primary,
    final Paint secondary,
  ) {
    final r = s * 0.20;
    canvas
      ..drawCircle(Offset(0, -s * 0.15), r, primary)
      ..drawCircle(Offset(-s * 0.15, s * 0.12), r, secondary)
      ..drawCircle(Offset(s * 0.15, s * 0.12), r, primary);
  }

  void _diamond(
    final Canvas canvas,
    final double s,
    final Paint primary,
    final Paint secondary,
  ) {
    final w = s * 0.30;
    canvas
      ..drawPath(
        Path()
          ..moveTo(0, -w)
          ..lineTo(w, 0)
          ..lineTo(0, w)
          ..lineTo(-w, 0)
          ..close(),
        primary,
      )
      ..drawCircle(Offset.zero, s * 0.08, secondary);
  }

  void _leaf(
    final Canvas canvas,
    final double s,
    final Paint primary,
    final Paint secondary,
  ) {
    final r = s * 0.26;
    canvas
      ..drawPath(
        Path()
          ..moveTo(0, -r)
          ..quadraticBezierTo(r, -r, r, 0)
          ..quadraticBezierTo(r, r, 0, r)
          ..quadraticBezierTo(-r, r, -r, 0)
          ..quadraticBezierTo(-r, -r, 0, -r)
          ..close(),
        primary,
      )
      ..drawCircle(Offset.zero, s * 0.07, secondary);
  }

  void _bars(
    final Canvas canvas,
    final double s,
    final Paint primary,
    final Paint secondary,
    final int bitsA,
    final int bitsB,
  ) {
    var y = -s * 0.18;
    for (var i = 0; i < 3; i++) {
      final bits = i == 0 ? bitsA : (i == 1 ? bitsB : bitsA ^ bitsB);
      final w = s * (0.34 + 0.22 * ((bits % 100) / 100));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, y), width: w, height: s * 0.11),
          Radius.circular(s * 0.055),
        ),
        i == 1 ? secondary : primary,
      );
      y += s * 0.18;
    }
  }

  void _ring(
    final Canvas canvas,
    final double s,
    final Paint primary,
    final Paint secondary,
  ) {
    canvas
      ..drawCircle(
        Offset.zero,
        s * 0.24,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.10
          ..color = primary.color,
      )
      ..drawCircle(Offset.zero, s * 0.08, secondary);
  }

  void _peaks(
    final Canvas canvas,
    final double s,
    final Paint primary,
    final Paint secondary,
  ) {
    final w = s * 0.28;
    canvas
      ..drawPath(
        Path()
          ..moveTo(0, -w)
          ..lineTo(w * 0.85, w * 0.55)
          ..lineTo(-w * 0.85, w * 0.55)
          ..close(),
        primary,
      )
      ..drawPath(
        Path()
          ..moveTo(0, w * 0.20)
          ..lineTo(w * 0.45, w * 0.85)
          ..lineTo(-w * 0.45, w * 0.85)
          ..close(),
        secondary,
      );
  }

  @override
  bool operator ==(final Object other) =>
      other is _IdenticonPainter && other.identity == identity;

  @override
  int get hashCode => identity.hashCode;

  @override
  bool shouldRepaint(final _IdenticonPainter oldDelegate) =>
      oldDelegate.identity != identity;
}

/// Initials from the display name through the roster's own word
/// extraction ([actorGutterLabel]) — `anton` → `A`, `afm coder` → `AC`;
/// an all-punctuation name falls back to the label's honest `ACTOR`,
/// hence `A`. Never empty.
String _monogramOf(final String displayName) => actorGutterLabel(
  displayName,
).split('-').take(2).map((final word) => word[0]).join();

/// The actor avatar: a deterministic identicon (models, agents) or an
/// initials monogram (humans), with a kind badge at size >= 32 and an
/// optional presence dot. Presence is a bool parameter — derivation
/// (bot listener loop, `lastSeenAt` recency) stays with the caller
/// (ADR 0007 §2).
final class ActorAvatar extends StatelessWidget {
  const ActorAvatar({
    required this.profile,
    this.size = 36,
    this.showPresence = false,
    this.presenceOnline = false,
    super.key,
  });

  /// Who is rendered — `actorId` alone picks the visuals, so the same
  /// identity keeps its avatar even if the name is edited later.
  final ActorProfile profile;

  /// Side length; the badge appears from 32 up, when there is room.
  final double size;

  /// Whether to render the presence dot at the bottom-right corner.
  final bool showPresence;

  /// The presence bool — online when the bot loop is live or
  /// `realm_actors.lastSeenAt` is recent (ADR 0007 §2).
  final bool presenceOnline;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final identity = switch (profile.kind) {
      ActorKind.human => _monogram(theme),
      _ => actorIdenticon(profile.actorId, size: size),
    };
    final badgeSize = (size * 0.38).clamp(10.0, 16.0);
    final dotSize = (size * 0.30).clamp(6.0, 12.0);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          KeyedSubtree(
            key: ValueKey('actor.avatar.${profile.actorId}'),
            child: identity,
          ),
          if (size >= 32)
            Positioned(
              right: -badgeSize * 0.15,
              top: -badgeSize * 0.15,
              child: _kindBadge(theme, badgeSize),
            ),
          if (showPresence)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: PresenceDot(
                  key: ValueKey('actor.presence.${profile.actorId}'),
                  online: presenceOnline,
                  size: dotSize,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The kind badge — a small surface circle hugging the top-right
  /// edge, lettered by what holds the agency (ADR 0003): `M`odel,
  /// `A`gent, `H`uman.
  Widget _kindBadge(final ThemeData theme, final double badgeSize) {
    final letter = switch (profile.kind) {
      ActorKind.model => 'M',
      ActorKind.agent => 'A',
      ActorKind.human => 'H',
    };
    return Container(
      width: badgeSize,
      height: badgeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: actorColor(profile.actorId)),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: badgeSize * 0.55,
          height: 1,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  /// The human's mark: initials on the identity tint, letters in the
  /// identity ink — deliberately a different species from the bots'
  /// blob+glyph, and quiet enough to sit beside it.
  Widget _monogram(final ThemeData theme) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: actorTint(profile.actorId),
      shape: BoxShape.circle,
    ),
    child: Text(
      _monogramOf(profile.displayName),
      style: TextStyle(
        color: actorColor(profile.actorId),
        fontSize: size * 0.36,
        height: 1,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );
}
