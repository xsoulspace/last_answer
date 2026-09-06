/// Fractional order keys for child ordering (ADR 0005 §2, "Block child
/// order" row): plain strings compared lexicographically, with `null`
/// standing for the beginning / end of the sibling sequence. Per infra ADR
/// 0029 §2, fractional rebalancing is a last_answer policy, not a kernel
/// type — these helpers are the whole of that policy.
///
/// Keys use the letters `a`–`z` as base-26 digits (value = letter index).
/// [fractionalBetween] returns a strictly-between key or `null` when the
/// two bounds are too close for the bounded key depth; the caller must
/// then rebalance the parent's keys with [freshKeys].
///
/// Pure Dart; no Flutter imports (headless_core constraint).
library;

/// Base-26 digit alphabet; digit value = index in this string.
const String _alphabet = 'abcdefghijklmnopqrstuvwxyz';

/// Number of digits (letters) available.
const int _base = 26;

/// Depth bound after which between-search gives up and the caller must
/// rebalance. Bounds key growth under adversarially tight neighbours.
const int _maxDepth = 32;

/// Middle digit used when extending a key ('n').
const int _middleDigit = 13;

/// Returns a key strictly between [before] and [after] in plain
/// lexicographic order (`String.compareTo`), or `null` when no such key
/// exists within the bounded depth. `null` bounds mean the beginning
/// ([before] == null) and end ([after] == null) of the sequence.
String? fractionalBetween(final String? before, final String? after) {
  final lo = before == null ? null : _digits(before);
  final hi = after == null ? null : _digits(after);
  final mid = _mid(lo, hi, 0);
  if (mid == null) return null;
  return String.fromCharCodes([
    for (final digit in mid) _alphabet.codeUnitAt(digit),
  ]);
}

/// Fresh, deterministic, evenly spaced keys for [count] children — the
/// rebalancing policy applied when [fractionalBetween] exhausts. The same
/// (ordered) child list on every replica yields the same keys.
List<String> freshKeys(final int count) {
  if (count <= 0) return const [];
  var width = 4;
  var slots = _base * _base * _base * _base;
  while (slots <= count + 1) {
    width++;
    slots *= _base;
  }
  final keys = <String>[];
  for (var j = 1; j <= count; j++) {
    // Lattice point in (0, slots): never zero, never repeated, because the
    // spacing slots/(count+1) is at least 1.
    var rest = (j * slots) ~/ (count + 1);
    final digits = List<int>.filled(width, 0);
    for (var d = width - 1; d >= 0; d--) {
      digits[d] = rest % _base;
      rest ~/= _base;
    }
    keys.add(
      String.fromCharCodes([
        for (final digit in digits) _alphabet.codeUnitAt(digit),
      ]),
    );
  }
  return keys;
}

List<int> _digits(final String key) => [
  for (final code in key.codeUnits)
    switch (code) {
      >= 0x61 && <= 0x7a => code - 0x61,
      _ => throw ArgumentError.value(key, 'key', 'not a fractional key'),
    },
];

/// Finds a digit list strictly between [lo] and [hi] (either may be
/// `null` = unbounded). Returns `null` when exhausted at [depth].
List<int>? _mid(final List<int>? lo, final List<int>? hi, final int depth) {
  if (depth > _maxDepth) return null;
  if (lo == null && hi == null) return const [_middleDigit];
  if (lo == null) {
    // Any nonempty key strictly below [hi].
    final h0 = hi![0];
    if (h0 > 0) return [h0 - 1];
    if (hi.length == 1) return null; // hi == 'a': nothing below it.
    final sub = _mid(null, hi.sublist(1), depth + 1);
    return sub == null ? null : [0, ...sub];
  }
  if (hi == null) {
    // Any key strictly above [lo]; keep keys bounded when possible by
    // incrementing the last digit, extending only past 'z'.
    final last = lo.last;
    if (last < _base - 1) {
      return [...lo.sublist(0, lo.length - 1), last + 1];
    }
    return [...lo, 0];
  }
  // Both bounds concrete: find the first differing digit.
  final common = lo.length < hi.length ? lo.length : hi.length;
  for (var i = 0; i < common; i++) {
    if (lo[i] != hi[i]) {
      final gap = hi[i] - lo[i];
      if (gap < 0) return null; // invalid input: lo >= hi
      if (gap >= 2) {
        return [...lo.sublist(0, i), lo[i] + gap ~/ 2];
      }
      // Adjacent digits: extend [lo] — strictly below [hi] because the
      // digit at [i] already sorts below [hi]'s, and strictly above [lo]
      // because it is a proper extension.
      return [...lo, _middleDigit];
    }
  }
  // One bound is a prefix of the other.
  if (lo.length == hi.length) return null; // equal keys
  if (lo.length < hi.length) {
    final sub = _mid(null, hi.sublist(lo.length), depth + 1);
    return sub == null ? null : [...lo, ...sub];
  }
  return null; // [hi] is a proper prefix of [lo]: hi < lo, invalid input
}
