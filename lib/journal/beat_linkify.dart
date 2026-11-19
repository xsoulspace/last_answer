/// The beat text's reference linkifier (v1, owner law 2026-11-16):
/// resolvable references become tappable spans routed through the
/// shell's ONE router; everything else renders as plain text — honest
/// absence, never a dead link.
///
/// The vocabulary (the shell's surface-id grammar plus the realm's
/// minted thread ids):
/// - `room:<threadId>` when the service knows the thread;
/// - `channel:<channelId>` when a live channel carries the id;
/// - `dm:<actorId>` when the roster has the actor;
/// - bare `thread-<hex>` ids when the service knows the full id (the
///   mint renders 12 random bytes as 24 hex chars; the length is the
///   mint's business — [knowsThread]-style resolvability is the law).
///
/// PURE: no service, no widgets, no build context — the caller
/// supplies the one resolvability oracle, and the tests exercise the
/// scan directly. A reference buried in a longer word (`xroom:abc`)
/// is prose, not a reference, and stays plain.
library;

/// The reference kinds the linkifier resolves (v1).
enum BeatRefKind { room, channel, dm, thread }

/// One resolved reference: the kind, the conversation surface id the
/// shell's ONE router speaks, and the token's verbatim text (ink is
/// data — the visible words never change).
typedef BeatLink = ({BeatRefKind kind, String surfaceId, String text});

/// One segment of a scanned beat text: a plain run ([link] null) or a
/// resolvable reference.
typedef BeatSegment = ({String text, BeatLink? link});

/// The prefixed grammar (`room:`/`channel:`/`dm:` — the shell's ONE
/// surface-id vocabulary) alternated with the realm's bare minted
/// thread id (`thread-` + the mint's hex run, greedy — the full id is
/// what the oracle must resolve).
final RegExp _refPattern = RegExp(
  r'room:[A-Za-z0-9_][A-Za-z0-9_.\-]*'
  r'|channel:[A-Za-z0-9_][A-Za-z0-9_.\-]*'
  r'|dm:[A-Za-z0-9_][A-Za-z0-9_.\-]*'
  '|thread-[0-9a-fA-F]+',
);

/// A token-extending character: a reference touching one of these on
/// its left is buried in a longer word (prose) — `xroom:abc`,
/// `channel:room:abc`'s inner token — and a bare thread id touching
/// one on its right is a longer word too (`thread-…-bis`, a longer
/// hex run: no minted id is a prefix of it).
final RegExp _wordChar = RegExp(r'[A-Za-z0-9_.\-:]');

/// Splits [text] into plain runs and resolvable references. The
/// resolvability oracle ([resolves]) decides per reference — a token
/// naming no live object stays plain text (the honest-absence law).
/// Text with no resolvable reference yields one plain segment.
List<BeatSegment> linkifyBeatText(
  final String text, {
  required final bool Function(BeatRefKind kind, String id) resolves,
}) {
  final segments = <BeatSegment>[];
  var cursor = 0;
  for (final match in _refPattern.allMatches(text)) {
    final start = match.start;
    final end = match.end;
    final token = match.group(0)!;
    // The boundary guard: prose keeps its words whole. (A prefixed
    // token's greedy id charset can only be buried on its LEFT; a
    // bare mint's hex run must also end at a word boundary — the
    // oracle resolves the FULL id, never a prefix.)
    if (start > 0 && _wordChar.hasMatch(text[start - 1])) continue;
    final isBareThread = !token.contains(':');
    if (isBareThread && end < text.length && _wordChar.hasMatch(text[end])) {
      continue;
    }
    final (BeatRefKind kind, String id) = switch (token) {
      final String t when t.startsWith('room:') =>
        (BeatRefKind.room, t.substring('room:'.length)),
      final String t when t.startsWith('channel:') =>
        (BeatRefKind.channel, t.substring('channel:'.length)),
      final String t when t.startsWith('dm:') =>
        (BeatRefKind.dm, t.substring('dm:'.length)),
      _ => (BeatRefKind.thread, token),
    };
    if (!resolves(kind, id)) continue;
    if (start > cursor) {
      segments.add((text: text.substring(cursor, start), link: null));
    }
    segments.add((
      text: token,
      link: (kind: kind, surfaceId: _surfaceIdOf(kind, id), text: token),
    ));
    cursor = end;
  }
  if (cursor < text.length) {
    segments.add((text: text.substring(cursor), link: null));
  }
  if (segments.isEmpty) return <BeatSegment>[(text: text, link: null)];
  return segments;
}

/// The conversation surface id a resolved reference opens (the shell's
/// ONE router vocabulary; a bare minted thread id opens as its room).
String _surfaceIdOf(final BeatRefKind kind, final String id) => switch (kind) {
  BeatRefKind.room => 'room:$id',
  BeatRefKind.thread => 'room:$id',
  BeatRefKind.channel => 'channel:$id',
  BeatRefKind.dm => 'dm:$id',
};
