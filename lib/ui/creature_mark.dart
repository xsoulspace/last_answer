/// CreatureMark (3d) — the actor's procedural mark as a small living
/// being (DESIGN.md v2, "The creature layer"): the six identicon shape
/// families are the SPECIES (deterministic from the actor id, exactly
/// as the identicon — same hash, same hues via `actorColor`), now with
/// eyes that carry the world's own truth.
///
/// The motion law (DESIGN v2 + the 3d mechanism split): the creature's
/// STATE ([CreatureMood]) arrives from LaWorld's derive law — never
/// invented here. Motion is widget-local and event-driven: one calm
/// blink per cycle while awake, ONE celebration hop when the mood
/// enters celebrating (400 ms, never looping), and static POSTURES for
/// sad/worried/asleep (a droop, a heavier lid, a sleeping tilt — no
/// ticker at all). Under reduced motion
/// ([MediaQuery.disableAnimationsOf]) the creature is fully static:
/// state renders through posture alone, the motion-free truth of the
/// same facts (the `_ThinkingPulse` house pattern).
///
/// Contract (DESIGN §6): the widget key AND the Semantics label are
/// `creature.<actorId>`; the mood word rides the Semantics hint —
/// hardcoded English contract vocabulary like `worldchat.typing`, not
/// localized prose. The kind badge and presence dot stay OUT (they
/// remain [ActorAvatar]'s job — a creature never becomes the only
/// carrier of actor type or presence): [eyesOnly] renders just the
/// eyes + focused glow as an overlay ON the existing avatar.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/la_world/creatures.dart';

/// The creature's calm-mark: a small [CustomPaint] being whose pose is
/// a pure function of ([actorId], [mood], phase). Quiet by law — it
/// lives in the chrome's calm and never demands attention.
final class CreatureMark extends StatefulWidget {
  const CreatureMark({
    required this.actorId,
    required this.mood,
    this.size = 22,
    this.eyesOnly = false,
    super.key,
  });

  /// Whose creature — species, hue and blink phase are pure functions
  /// of this id (never random per build).
  final String actorId;

  /// The honest mood from the derive law (creatures.dart).
  final CreatureMood mood;

  /// Side length; 22 is the rail avatar's everyday home (DESIGN v2).
  final double size;

  /// Overlay mode: eyes + focused glow only, no species body — the
  /// people row's AUGMENT over [ActorAvatar]'s existing identicon (its
  /// badge, presence dot and keys stay untouched).
  final bool eyesOnly;

  @override
  State<CreatureMark> createState() => _CreatureMarkState();
}

class _CreatureMarkState extends State<CreatureMark>
    with TickerProviderStateMixin {
  /// The blink clock: one sparse, sub-200 ms lid close per ~5.6 s
  /// cycle, phase-offset per actor ([blinkSeedOf]) so a cast never
  /// blinks in lockstep. Runs ONLY for awake moods under motion.
  late final AnimationController _life = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5600),
  );

  /// The ONE settlement celebration: a 400 ms hop, played once when
  /// the mood ENTERS celebrating (DESIGN v2 — once per settled pass,
  /// never a loop), then the raised static pose holds.
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  bool _motion = false;

  /// The hop is ONE-SHOT per celebrating entry (DESIGN v2: once per
  /// settled pass, never a loop) — a remount mid-celebration shows the
  /// raised static pose, not a second party.
  bool _hopped = false;

  @override
  void initState() {
    super.initState();
    if (widget.mood == CreatureMood.celebrating) _hop.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = !MediaQuery.disableAnimationsOf(context);
    _maybeHop();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant final CreatureMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood == widget.mood) return;
    if (widget.mood != CreatureMood.celebrating) _hopped = false;
    _maybeHop();
    _syncTicker();
  }

  void _maybeHop() {
    if (widget.mood != CreatureMood.celebrating || _hopped) return;
    _hopped = true;
    if (_motion) {
      _hop.forward(from: 0);
    } else {
      _hop.value = 1;
    }
  }

  /// Awake moods may blink; sad/worried/asleep are pure static
  /// posture — no ticker, no frames (the calm-chrome law).
  bool get _awake => switch (widget.mood) {
    CreatureMood.calm ||
    CreatureMood.focused ||
    CreatureMood.celebrating => true,
    CreatureMood.worried || CreatureMood.sad || CreatureMood.asleep => false,
  };

  void _syncTicker() {
    if (_motion && _awake) {
      if (!_life.isAnimating) _life.repeat();
    } else if (_life.isAnimating) {
      _life
        ..stop()
        // Never freeze mid-blink: the stopped pose is the open eye.
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _life.dispose();
    _hop.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Semantics(
    key: ValueKey('creature.${widget.actorId}'),
    label: 'creature.${widget.actorId}',
    hint: widget.mood.name,
    child: RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_life, _hop]),
          builder: (final context, final _) => CustomPaint(
            size: Size.square(widget.size),
            painter: _CreaturePainter(
              actorId: widget.actorId,
              mood: widget.mood,
              eyesOnly: widget.eyesOnly,
              phase: _motion ? _life.value : 0,
              hop: widget.mood == CreatureMood.celebrating
                  ? (_motion ? _hop.value : 1)
                  : 0,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Paints the creature: species body (the identicon's own geometry and
/// two-tone hue) + eyes whose lids, gaze height and tilt are the mood's
/// posture. Value-signature [shouldRepaint] — repaints only when a
/// field actually changed (the preview_canvas discipline).
@immutable
final class _CreaturePainter extends CustomPainter {
  const _CreaturePainter({
    required this.actorId,
    required this.mood,
    required this.eyesOnly,
    required this.phase,
    required this.hop,
  });

  final String actorId;
  final CreatureMood mood;
  final bool eyesOnly;

  /// Blink clock position 0..1 (0 when static).
  final double phase;

  /// Celebration hop position 0..1 (1 = the raised static pose).
  final double hop;

  @override
  void paint(final Canvas canvas, final Size size) {
    final s = size.shortestSide;
    if (s <= 0) return;
    final base = HSLColor.fromColor(actorColor(actorId));
    final hue = base.hue;
    final primary = Paint()..color = base.toColor();
    final secondary = Paint()
      ..color = HSLColor.fromAHSL(1, hue, 0.30, 0.52).toColor();
    final sclera = Paint()
      ..color = HSLColor.fromAHSL(1, hue, 0.22, 0.94).toColor();
    final pupil = Paint()
      ..color = HSLColor.fromAHSL(1, hue, 0.50, 0.20).toColor();

    // The per-actor blink phase offset (deterministic, never random).
    final seedPhase = (blinkSeedOf(actorId) % 997) / 997;
    final t = (phase + seedPhase) % 1.0;
    // One quick lid close in the last 7% of the cycle.
    final blinkLocal = (t - 0.93) / 0.07;
    final blink = blinkLocal >= 0 && blinkLocal <= 1
        ? math.sin(blinkLocal * math.pi)
        : 0.0;

    final lid = switch (mood) {
      CreatureMood.asleep => 1.0,
      CreatureMood.sad => 0.45,
      CreatureMood.worried => 0.30,
      CreatureMood.calm ||
      CreatureMood.focused ||
      CreatureMood.celebrating => blink,
    };
    final dy = switch (mood) {
      // Hop once, then hold the raised pose (the static celebration).
      CreatureMood.celebrating => -(0.04 + 0.09 * math.sin(math.pi * hop)),
      CreatureMood.sad => 0.05,
      CreatureMood.worried => 0.03,
      CreatureMood.asleep => 0.07,
      CreatureMood.calm || CreatureMood.focused => 0.0,
    };
    final tilt = switch (mood) {
      CreatureMood.asleep => 0.16,
      CreatureMood.sad => 0.05,
      _ => 0.0,
    };

    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2 + dy * s)
      ..rotate(tilt);

    // Focused: a steady soft glow — never a wiggle (DESIGN v2).
    if (mood == CreatureMood.focused) {
      canvas.drawCircle(
        Offset.zero,
        s * 0.47,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.05
          ..color = primary.color.withValues(alpha: 0.30),
      );
    }

    if (!eyesOnly) {
      canvas.drawCircle(
        Offset.zero,
        s / 2,
        Paint()..color = actorTint(actorId),
      );
      final hs = creatureHash('$actorId\u0000shape');
      final h = creatureHash(actorId);
      canvas
        ..save()
        ..rotate(((hs >> 5) % 24) * 15.0 * math.pi / 180)
        ..scale(0.66);
      switch (speciesOf(actorId)) {
        case CreatureSpecies.triad:
          _triad(canvas, s, primary, secondary);
        case CreatureSpecies.diamond:
          _diamond(canvas, s, primary, secondary);
        case CreatureSpecies.leaf:
          _leaf(canvas, s, primary, secondary);
        case CreatureSpecies.bars:
          _bars(
            canvas,
            s,
            primary,
            secondary,
            (h >> 8) & 0xFFFF,
            (hs >> 9) & 0x7FFF,
          );
        case CreatureSpecies.ring:
          _ring(canvas, s, primary, secondary);
        case CreatureSpecies.peaks:
          _peaks(canvas, s, primary, secondary);
      }
      canvas.restore();
    }

    // The face: two eyes at the mark's center, lids carrying the mood.
    final eyeR = s * 0.075;
    final cy = -s * 0.02;
    _eye(canvas, Offset(-s * 0.125, cy), eyeR, lid, sclera, pupil);
    _eye(canvas, Offset(s * 0.125, cy), eyeR, lid, sclera, pupil);
    canvas.restore();
  }

  /// One eye: a sclera disc with a pupil, the lid closing from the top
  /// (a clip, so it works over any body — and in [eyesOnly] overlay).
  void _eye(
    final Canvas canvas,
    final Offset c,
    final double r,
    final double lid,
    final Paint sclera,
    final Paint pupil,
  ) {
    final closed = lid.clamp(0.0, 1.0).toDouble();
    if (closed < 0.99) {
      canvas
        ..save()
        ..clipRect(
          Rect.fromLTWH(c.dx - r, c.dy - r + 2 * r * closed, 2 * r, 2 * r),
        )
        ..drawCircle(c, r, sclera)
        ..drawCircle(c + Offset(0, r * 0.18), r * 0.45, pupil)
        ..restore();
    }
    if (closed > 0.05) {
      // The lid line itself — a quiet stroke in the identity ink.
      final y = c.dy - r + 2 * r * closed;
      canvas.drawLine(
        Offset(c.dx - r, y),
        Offset(c.dx + r, y),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, r * 0.28)
          ..strokeCap = StrokeCap.round
          ..color = pupil.color,
      );
    }
  }

  // ---- the six species: the identicon's own geometry (actor_avatar) --

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
  bool shouldRepaint(final _CreaturePainter oldDelegate) =>
      oldDelegate.actorId != actorId ||
      oldDelegate.mood != mood ||
      oldDelegate.eyesOnly != eyesOnly ||
      oldDelegate.phase != phase ||
      oldDelegate.hop != hop;
}
