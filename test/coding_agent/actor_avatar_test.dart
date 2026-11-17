// ADR 0007 — the actor avatar gate: deterministic identity, kind-aware
// rendering, presence plumbing. Golden-free: determinism is asserted by
// comparing painters from two builds, and the hash is pinned by an
// independent FNV-1a reimplementation so a swap to a process-randomized
// hash (String.hashCode) fails here — on every device.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_ui/la_ui.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_presence.dart';

/// Independent FNV-1a reimplementation — pins the hash algorithm behind
/// `actorColor`/`actorIdenticon`, so avatars stay identical across
/// edits, devices and Dart versions.
int _fnv1a(final String s) {
  var h = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

const _agent = ActorProfile(
  actorId: 'afm-coder',
  displayName: 'afm coder',
  kind: ActorKind.agent,
  brainRef: 'afm-3',
  role: 'coder',
);

const _human = ActorProfile(
  actorId: 'anton',
  displayName: 'anton',
  kind: ActorKind.human,
);

Future<void> _pump(final WidgetTester tester, final Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
  await tester.pump();
}

/// The identicon painter under [anchor] — always scoped, because
/// MaterialApp's debug banner carries its own framework CustomPaint.
CustomPainter _painterUnder(final WidgetTester tester, final Key anchor) =>
    tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byKey(anchor),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter!;

void main() {
  group('deterministic identity (ADR 0007)', () {
    test('actorColor: pure function — same id, same color', () {
      expect(actorColor('afm-coder'), actorColor('afm-coder'));
      expect(actorColor('anton'), actorColor('anton'));
    });

    test('actorColor: hash pinned to FNV-1a + golden-angle hue', () {
      final h = _fnv1a('afm-coder');
      // Saturation/lightness pinned at the de-Material values
      // (0.45/0.36 — the ≥4.5:1 ink law, shell-de-material-plan §2);
      // only the HUE is derived from the hash. A change here is a
      // conscious design decision, never drift.
      final expected = HSLColor.fromAHSL(
        1,
        (h * 137.508) % 360,
        0.45,
        0.36,
      ).toColor();
      expect(actorColor('afm-coder'), expected);
    });

    test('different ids distribute hues across the wheel', () {
      const ids = [
        'alpha', 'bravo', 'charlie', 'delta', 'echo', 'foxtrot', 'golf',
        'hotel', 'india', 'juliet', 'kilo', 'lima', 'mike', 'november',
        'oscar', 'papa', 'quebec', 'romeo', 'sierra', 'tango', 'uniform',
        'victor', 'whiskey', 'xray',
      ];
      final hues = ids
          .map((final id) => HSLColor.fromColor(actorColor(id)).hue.round())
          .toSet();
      expect(hues, hasLength(greaterThan(1)),
          reason: 'not all ids share one hue');
      expect(hues.length, greaterThanOrEqualTo(12),
          reason: '24 ids should spread well over the hue wheel');
    });

    testWidgets('actorIdenticon: same id → identical painter across builds',
        (final tester) async {
      const anchor = Key('probe.identicon');
      await _pump(
        tester,
        KeyedSubtree(
          key: anchor,
          child: actorIdenticon('afm-coder', size: 24),
        ),
      );
      final first = _painterUnder(tester, anchor);

      await _pump(
        tester,
        KeyedSubtree(
          key: anchor,
          child: Column(children: [actorIdenticon('afm-coder', size: 48)]),
        ),
      );
      final second = _painterUnder(tester, anchor);
      expect(first, equals(second));

      await _pump(
        tester,
        KeyedSubtree(key: anchor, child: actorIdenticon('anton', size: 24)),
      );
      final other = _painterUnder(tester, anchor);
      expect(other, isNot(equals(first)),
          reason: 'a different id draws a different identicon');
    });

    testWidgets('ActorAvatar: same profile → identical painter across builds',
        (final tester) async {
      const anchor = ValueKey('actor.avatar.afm-coder');
      await _pump(tester, const ActorAvatar(profile: _agent));
      final first = _painterUnder(tester, anchor);
      await _pump(tester, const ActorAvatar(profile: _agent, size: 48));
      final second = _painterUnder(tester, anchor);
      expect(first, equals(second));
    });
  });

  group('ActorAvatar rendering', () {
    testWidgets('carries the deterministic identity key', (final tester) async {
      await _pump(tester, const ActorAvatar(profile: _agent));
      expect(find.byKey(const ValueKey('actor.avatar.afm-coder')),
          findsOneWidget);
    });

    testWidgets('agents render the identicon, never a monogram',
        (final tester) async {
      const anchor = ValueKey('actor.avatar.afm-coder');
      await _pump(tester, const ActorAvatar(profile: _agent));
      expect(
        find.descendant(
          of: find.byKey(anchor),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.text('AC'), findsNothing,
          reason: 'bots are blobs, not initials');
      expect(find.text('A'), findsOneWidget, reason: 'agent badge at 36');
    });

    testWidgets('humans render an initials monogram', (final tester) async {
      const anchor = ValueKey('actor.avatar.anton');
      await _pump(tester, const ActorAvatar(profile: _human));
      expect(find.text('A'), findsOneWidget, reason: 'anton → A');
      expect(
        find.descendant(
          of: find.byKey(anchor),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
        reason: 'humans are monograms, not blobs',
      );
      expect(find.text('H'), findsOneWidget, reason: 'human badge');
    });

    testWidgets('models badge as M', (final tester) async {
      const model = ActorProfile(actorId: 'glm', displayName: 'glm flash');
      await _pump(tester, const ActorAvatar(profile: model));
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('no badge below size 32', (final tester) async {
      const anchor = ValueKey('actor.avatar.afm-coder');
      await _pump(tester, const ActorAvatar(profile: _agent, size: 24));
      expect(find.text('A'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(anchor),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
        reason: 'the identicon itself still renders',
      );
    });

    testWidgets('presence dot: off by default, on/off with the bool',
        (final tester) async {
      const dotKey = ValueKey('actor.presence.afm-coder');

      await _pump(
        tester,
        const ActorAvatar(
          profile: _agent,
          showPresence: true,
          presenceOnline: true,
        ),
      );
      expect(find.byKey(dotKey), findsOneWidget);
      expect(tester.widget<PresenceDot>(find.byType(PresenceDot)).online,
          isTrue);

      await _pump(tester, const ActorAvatar(profile: _agent));
      expect(find.byKey(dotKey), findsNothing);
      expect(find.byType(PresenceDot), findsNothing);

      await _pump(
        tester,
        const ActorAvatar(profile: _agent, showPresence: true),
      );
      expect(find.byKey(dotKey), findsOneWidget);
      expect(tester.widget<PresenceDot>(find.byType(PresenceDot)).online,
          isFalse);
    });
  });

  group('PresenceDot', () {
    testWidgets('online renders the presence green at the given size',
        (final tester) async {
      await _pump(tester, const PresenceDot(online: true));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, kActorPresenceOnline);
      expect(tester.getSize(find.byType(Container)).width, 8);
    });

    testWidgets('offline renders the quiet theme outline',
        (final tester) async {
      await _pump(tester, const PresenceDot(online: false));
      final context = tester.element(find.byType(PresenceDot));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      // The kit token (v6): the quiet outline is inkQuiet, not M3 outline.
      expect(decoration.color, context.laUi.inkQuiet);
      expect(decoration.color, isNot(kActorPresenceOnline));
    });
  });
  // Wave N2 — the owner-set mark wins over the derived identity: a
  // curated glyph renders its Icon, a raw emoji renders verbatim, and
  // an absent mark keeps the derivation (the channel-icon law).
  group('the owner-set mark (wave N2)', () {
    testWidgets('a curated glyph renders its Icon', (final tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ActorAvatar(
              profile: ActorProfile(
                actorId: 'scout',
                displayName: 'Scout',
                avatar: 'spark',
              ),
              size: 40,
            ),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('actor.avatar.scout')),
          matching: find.byIcon(kActorAvatarGlyphs['spark']!),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a raw emoji renders verbatim; absent keeps the '
        'derivation', (final tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ActorAvatar(
                  profile: ActorProfile(
                    actorId: 'owl',
                    displayName: 'Owl',
                    avatar: '🦉',
                  ),
                  size: 40,
                ),
                ActorAvatar(
                  profile: ActorProfile(
                    actorId: 'bare',
                    displayName: 'Bare',
                  ),
                  size: 40,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('🦉'), findsOneWidget);
      // The derived identicon paints; no emoji text for the bare one.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('actor.avatar.bare')),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
    });
  });
}
