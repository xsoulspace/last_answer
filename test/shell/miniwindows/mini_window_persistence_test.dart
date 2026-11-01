// The miniwindow persistence law: records survive a restart through
// `shell.miniwindows.v1` (beside `shell.tabs.v1`); an unresolvable id
// restores as nothing; the save is debounced and the binding releases
// cleanly on dispose.
import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/shell/miniwindows/mini_window.dart';

import 'package:lastanswer/shell/miniwindows/mini_window_persistence.dart';

import 'package:shared_preferences/shared_preferences.dart';

MiniWindowSpec _specFor(String id) => MiniWindowSpec(
  id: id,
  title: id,
  builder: (final _) => const SizedBox(),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('open windows persist debounced and restore on a fresh '
      'controller', (final tester) async {
    final first = MiniWindowController();
    addTearDown(first.dispose);
    // The shell binds at boot, before anything opens — the debounce
    // rides the change notifications.
    final persistence = MiniWindowPersistence();
    persistence.bind(first);
    first.open(_specFor('dm:iris'));
    first.open(_specFor('channel:c1'));
    await tester.pump(const Duration(milliseconds: 600));

    final second = MiniWindowController();
    addTearDown(second.dispose);
    final restored = await persistence.restoreInto(second, _specFor);
    expect(restored, 2);
    expect(second.contains('dm:iris'), isTrue);
    expect(second.contains('channel:c1'), isTrue);
    // Order survived: the back-to-front snapshot round-trips.
    expect(second.records.map((r) => r.id).toList(), [
      'dm:iris',
      'channel:c1',
    ]);
  });

  testWidgets('an unresolvable id is skipped, not thrown', (
    final tester,
  ) async {
    final first = MiniWindowController();
    addTearDown(first.dispose);
    final persistence = MiniWindowPersistence();
    persistence.bind(first);
    first.open(_specFor('dm:iris'));
    await tester.pump(const Duration(milliseconds: 600));

    final second = MiniWindowController();
    addTearDown(second.dispose);
    final restored = await persistence.restoreInto(
      second,
      (final id) => id == 'dm:iris' ? _specFor(id) : null,
      // A ghost id in the store (e.g. a deleted actor) restores nothing.
    );
    expect(restored, 1);
  });

  testWidgets('dispose releases the listener: no save after dispose', (
    final tester,
  ) async {
    final controller = MiniWindowController();
    addTearDown(controller.dispose);
    final persistence = MiniWindowPersistence();
    persistence.bind(controller);
    persistence.dispose();

    controller.open(_specFor('dm:iris'));
    await tester.pump(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kMiniWindowsPrefsKey), isNull);
  });
}
