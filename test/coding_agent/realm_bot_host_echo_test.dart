import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';

void main() {
  // The echo guard's window logic, extracted pure so it tests without a
  // live brain: a small model's verbatim repeat — of its OWN last word
  // or of the human's beat (the observed Akio failure) — is dropped.
  group('normalizeReplyText', () {
    test('lowercase, collapse whitespace, trim', () {
      expect(
        normalizeReplyText('  Sounds   GOOD\nto me!\t'),
        'sounds good to me!',
      );
    });
  });

  group('isEchoOfRecent', () {
    final thread = <String>[
      'What should we ship first?',
      'I say the onboarding flow.',
      'Onboarding it is.',
      'Sounds good to me!',
    ];

    test('verbatim echo of another participant is dropped', () {
      // The reported failure: Akio echoed the human verbatim.
      expect(
        isEchoOfRecent(
          reply: 'What should we ship first?',
          recentBeats: thread,
        ),
        isTrue,
      );
    });

    test('verbatim echo of the bot itself is dropped', () {
      expect(
        isEchoOfRecent(
          reply: 'I say the onboarding flow.',
          recentBeats: thread,
        ),
        isTrue,
      );
    });

    test('case, layout and padding do not hide an echo', () {
      expect(
        isEchoOfRecent(
          reply: '  SOUNDS   good\nto ME!!  ',
          recentBeats: thread,
        ),
        isTrue,
      );
    });

    test('a padded echo (containment of real content) is dropped', () {
      expect(
        isEchoOfRecent(
          reply: 'Sounds good to me! Ha.',
          recentBeats: thread,
        ),
        isTrue,
        reason: 'the beat (>= 8 chars) is contained in the padded reply',
      );
    });

    test('a fresh reply passes', () {
      expect(
        isEchoOfRecent(
          reply: 'Then the export path can wait a week.',
          recentBeats: thread,
        ),
        isFalse,
      );
    });

    test('only the last 6 beats count', () {
      final longThread = <String>[
        for (var i = 0; i < 10; i++) 'beat number $i about topic $i',
      ];
      // Beat 0 falls out of the 6-beat window: echoing it is legal again.
      expect(
        isEchoOfRecent(reply: longThread.first, recentBeats: longThread),
        isFalse,
      );
      // The most recent beat is still an echo.
      expect(
        isEchoOfRecent(reply: longThread.last, recentBeats: longThread),
        isTrue,
      );
    });

    test('containment alone needs 8+ chars on the shorter side', () {
      // "ok" echoing inside a longer reply is NOT dropped on containment
      // grounds (too short to be an echo signature)…
      final shortThread = <String>['ok'];
      expect(
        isEchoOfRecent(
          reply: 'looking at it, ok then',
          recentBeats: shortThread,
        ),
        isFalse,
      );
      // …but a VERBATIM repeat is an echo at any length: dropping it
      // costs nothing (the room already heard it) and stops degenerate
      // short-word loops.
      expect(isEchoOfRecent(reply: 'ok', recentBeats: shortThread), isTrue);
    });

    test('empty replies are not echoes (handled upstream)', () {
      expect(isEchoOfRecent(reply: '', recentBeats: thread), isFalse);
    });

    test('an empty thread echoes nothing', () {
      expect(
        isEchoOfRecent(reply: 'anything', recentBeats: <String>[]),
        isFalse,
      );
    });
  });
}
