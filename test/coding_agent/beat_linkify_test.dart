// The beat text's reference linkifier (v1): resolvable references
// (`room:`/`channel:`/`dm:` tokens, bare minted `thread-` ids) become
// linked segments routed through the shell's ONE router; every
// non-resolvable token stays plain text — honest absence, never a
// dead link. The suite pins the PURE scan: the oracle is a fixture
// set, no service, no widgets.
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/data_journal/beat_linkify.dart';

void main() {
  // The fixture world's live objects: two known threads (a minted
  // 24-hex id and a short fixture id), one registered channel, one
  // rostered actor. Anything else is honestly unknown.
  const knownThreads = <String>{
    'thread-abcdef012345abcdef012345',
    'thread-aaaaaaaaaaaa',
  };
  const knownChannels = <String>{'channel-0123456789ab'};
  const knownActors = <String>{'actor-scout'};

  bool resolves(final BeatRefKind kind, final String id) => switch (kind) {
    BeatRefKind.room || BeatRefKind.thread => knownThreads.contains(id),
    BeatRefKind.channel => knownChannels.contains(id),
    BeatRefKind.dm => knownActors.contains(id),
  };

  /// The links of a scanned text (the plain runs assert through
  /// [segments] where the shape matters).
  List<BeatLink> links(final String text) => [
    for (final segment in linkifyBeatText(text, resolves: resolves))
      if (segment.link != null) segment.link!,
  ];

  test('text with no references yields one plain segment', () {
    final segments = linkifyBeatText(
      'just words, nothing resolvable',
      resolves: resolves,
    );
    expect(segments, hasLength(1));
    expect(segments.single.text, 'just words, nothing resolvable');
    expect(segments.single.link, isNull);
  });

  test('empty text yields one empty plain segment', () {
    final segments = linkifyBeatText('', resolves: resolves);
    expect(segments, hasLength(1));
    expect(segments.single.text, '');
    expect(segments.single.link, isNull);
  });

  test('a known room: token links to its room surface verbatim', () {
    final segments = linkifyBeatText(
      'see room:thread-aaaaaaaaaaaa for the plan',
      resolves: resolves,
    );
    expect(segments, hasLength(3));
    expect(segments[0].text, 'see ');
    expect(segments[1].text, 'room:thread-aaaaaaaaaaaa');
    expect(segments[1].link!.surfaceId, 'room:thread-aaaaaaaaaaaa');
    expect(segments[1].link!.kind, BeatRefKind.room);
    expect(segments[2].text, ' for the plan');
  });

  test('an unknown room: token stays plain text (honest absence)', () {
    expect(links('room:thread-000000000000'), isEmpty);
    // The bare `room:` prefix with no id is prose too.
    expect(links('the room: prefix'), isEmpty);
  });

  test('a live channel: token links to its channel surface', () {
    final segments = linkifyBeatText(
      'channel:channel-0123456789ab: the general room',
      resolves: resolves,
    );
    // The token opens the text: link first, then the prose tail.
    expect(segments, hasLength(2));
    expect(segments[0].link!.kind, BeatRefKind.channel);
    expect(segments[0].link!.surfaceId, 'channel:channel-0123456789ab');
    // The prose colon after the token does not swallow it.
    expect(segments[1].text, ': the general room');
  });

  test('an unknown channel: token stays plain', () {
    expect(links('channel:channel-ffffffffffff'), isEmpty);
  });

  test('a rostered dm: token links to the DM surface', () {
    final segments = linkifyBeatText(
      'dm:actor-scout said so',
      resolves: resolves,
    );
    expect(segments, hasLength(2));
    expect(segments[0].link!.kind, BeatRefKind.dm);
    expect(segments[0].link!.surfaceId, 'dm:actor-scout');
    expect(segments[1].text, ' said so');
  });

  test('an unrostered dm: token stays plain', () {
    expect(links('dm:actor-ghost'), isEmpty);
  });

  test('a bare minted thread id links when the full id resolves', () {
    // The mint renders 12 bytes as 24 hex chars — the FULL id is what
    // the oracle must resolve (the scan is greedy over the hex run).
    final segments = linkifyBeatText(
      'spawned thread-abcdef012345abcdef012345 for it',
      resolves: resolves,
    );
    expect(segments, hasLength(3));
    expect(segments[1].link!.kind, BeatRefKind.thread);
    expect(segments[1].link!.surfaceId, 'room:thread-abcdef012345abcdef012345');
    expect(segments[1].text, 'thread-abcdef012345abcdef012345');
  });

  test('an unknown bare thread id stays plain', () {
    expect(links('thread-ffffffffffffffffffffffff'), isEmpty);
  });

  test('a reference buried in a longer word stays plain', () {
    // The boundary guard: prose keeps its words whole.
    expect(links('xroom:thread-aaaaaaaaaaaa'), isEmpty);
    expect(links('see thread-aaaaaaaaaaaa-bis here'), isEmpty);
    expect(links('see thread-ffffffffffffffffffffffff1 here'), isEmpty);
  });

  test('nested prefixed tokens do not half-link', () {
    // `channel:room:…` — the outer token resolves to nothing (no
    // channel named `room`), the inner token touches the `:` on its
    // left: all plain, never a partial link.
    expect(links('channel:room:thread-aaaaaaaaaaaa'), isEmpty);
  });

  test('multiple references segment in order', () {
    const text =
        'room:thread-aaaaaaaaaaaa and dm:actor-scout and '
        'channel:channel-0123456789ab';
    final segments = linkifyBeatText(text, resolves: resolves);
    expect(
      [
        for (final segment in segments)
          if (segment.link != null) segment.link!.surfaceId,
      ],
      <String>[
        'room:thread-aaaaaaaaaaaa',
        'dm:actor-scout',
        'channel:channel-0123456789ab',
      ],
    );
    // The plain runs carry exactly the words between the tokens.
    expect(segments, hasLength(5));
    expect(segments[0].link, isNotNull);
    expect(segments[1].text, ' and ');
    expect(segments[3].text, ' and ');
  });

  test('resolved and unresolved references mix honestly', () {
    final segments = linkifyBeatText(
      'room:thread-aaaaaaaaaaaa works, room:thread-000000000000 does not',
      resolves: resolves,
    );
    final linked = [
      for (final segment in segments)
        if (segment.link != null) segment.text,
    ];
    expect(linked, <String>['room:thread-aaaaaaaaaaaa']);
    // The unknown token is still PRESENT — as plain words.
    expect(
      segments.map((final segment) => segment.text).join(),
      'room:thread-aaaaaaaaaaaa works, room:thread-000000000000 does not',
    );
  });

  test('a room: token over a minted id rides one surface grammar', () {
    // `room:` + the full minted id — the id charset covers the hex
    // run, so the prefixed and bare forms resolve identically.
    final linked = links('room:thread-abcdef012345abcdef012345');
    expect(linked.single.surfaceId, 'room:thread-abcdef012345abcdef012345');
    expect(linked.single.kind, BeatRefKind.room);
  });
}
