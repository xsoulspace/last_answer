// The unified views layout's model law (WAVE 5): unique ids, one
// conversation slot (dm:/channel: reuse it in place — the Discord
// flow), the last tab is immortal, the picker is session chrome, pins
// are independent of tabs (a view may be tab AND pin; unpinning
// removes the pin only), and the persisted JSON decodes tolerantly —
// including the ONE-TIME migration input (the retired shell.tabs.v1
// shape decodes with the default People pin). The legacy pane-tree
// flatten (the migration's deeper input) is covered here too.
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/view_layout.dart';

void main() {
  group('normalization', () {
    test('the default layout: conversations face, People the default pin', () {
      final layout = ViewLayout();
      expect(layout.tabs, [kConversationsSurfaceId]);
      expect(layout.active, 0);
      expect(layout.activeId, kConversationsSurfaceId);
      expect(layout.pinned, [kPeopleSurfaceId]);
      expect(layout.focusedDockId, kPeopleSurfaceId);
      expect(layout.isPinned(kPeopleSurfaceId), isTrue);
    });

    test('duplicate ids keep their first occurrence (tabs and pins)', () {
      final layout = ViewLayout(tabs: const ['a', 'b', 'a'], active: 2);
      expect(layout.tabs, ['a', 'b']);
      // The surviving ids are [a, b]; the out-of-range focus clamps.
      expect(layout.active, 1);
      final pinned = ViewLayout(
        tabs: const ['a'],
        pinned: const ['x', 'y', 'x'],
      );
      expect(pinned.pinned, ['x', 'y']);
    });

    test('an empty tab strip falls back to conversations', () {
      final layout = ViewLayout(tabs: const []);
      expect(layout.tabs, [kConversationsSurfaceId]);
      expect(layout.active, 0);
    });

    test('an out-of-range active index clamps', () {
      expect(ViewLayout(tabs: const ['a', 'b'], active: 9).active, 1);
      expect(ViewLayout(tabs: const ['a', 'b'], active: -3).active, 0);
    });

    test('value equality: tabs, active, pins, dock focus', () {
      expect(ViewLayout(tabs: const ['a']), ViewLayout(tabs: const ['a']));
      expect(
        ViewLayout(tabs: const ['a']),
        isNot(ViewLayout(tabs: const ['b'])),
      );
      expect(
        ViewLayout(tabs: const ['a', 'b'], active: 1),
        isNot(ViewLayout(tabs: const ['a', 'b'])),
      );
      expect(
        ViewLayout(tabs: const ['a'], pinned: const ['people']),
        isNot(ViewLayout(tabs: const ['a'], pinned: const [])),
      );
      expect(
        ViewLayout(
          tabs: const ['a'],
          pinned: const ['x', 'y'],
          dockFocus: 'y',
        ),
        isNot(ViewLayout(
          tabs: const ['a'],
          pinned: const ['x', 'y'],
          dockFocus: 'x',
        )),
      );
    });
  });

  group('open (bar taps)', () {
    test('a new station opens right of the active tab and focuses it', () {
      final layout = ViewLayout(tabs: const ['a', 'b']);
      final next = layout.open('c');
      expect(next.tabs, ['a', 'c', 'b']);
      expect(next.active, 1);
    });

    test('an already-open station just focuses', () {
      final layout = ViewLayout(tabs: const ['a', 'b']);
      expect(layout.open('b').tabs, ['a', 'b']);
      expect(layout.open('b').active, 1);
    });
  });

  group('openConversation (the rail flow)', () {
    test('a rail selection replaces the slot id in place', () {
      final layout = ViewLayout(
        tabs: const [kConversationsSurfaceId, 'browser'],
      );
      final next = layout.openConversation('dm:actor-x');
      expect(next.tabs, ['dm:actor-x', 'browser']);
      expect(next.active, 0);
    });

    test('selecting another conversation keeps the count, focuses it', () {
      // The rail click SHOWS the conversation (Discord flow): the slot
      // keeps its position and takes the focus, the tab count is
      // unchanged.
      final layout = ViewLayout(
        tabs: const ['dm:actor-x', 'browser', 'inspector'],
        active: 2,
      );
      final next = layout.openConversation('channel:c1');
      expect(next.tabs, ['channel:c1', 'browser', 'inspector']);
      expect(next.active, 0);
    });

    test('re-selecting the focused conversation is a no-op', () {
      final layout = ViewLayout(tabs: const ['dm:actor-x', 'browser']);
      expect(layout.openConversation('dm:actor-x'), same(layout));
    });

    test('an ordinary rail selection never destroys explicit tabs', () {
      // The dm:actor-y tab was spawned explicitly (⌘-click intent); a
      // plain rail selection of dm:actor-x focuses the slot and leaves
      // the explicit tab alone.
      final layout = ViewLayout(
        tabs: const ['dm:actor-x', 'dm:actor-y', 'browser'],
        active: 1,
      );
      final next = layout.openConversation('dm:actor-x');
      expect(next.tabs, ['dm:actor-x', 'dm:actor-y', 'browser']);
      expect(next.active, 0);
    });

    test('forceNew spawns a dedicated tab next to the slot', () {
      final layout = ViewLayout(tabs: const ['dm:actor-x', 'browser']);
      final next = layout.openConversation('dm:actor-y', forceNew: true);
      expect(next.tabs, ['dm:actor-x', 'dm:actor-y', 'browser']);
      expect(next.active, 1);
    });

    test('forceNew on an open conversation focuses it instead', () {
      final layout = ViewLayout(tabs: const ['dm:actor-x', 'dm:actor-y']);
      final next = layout.openConversation('dm:actor-y', forceNew: true);
      expect(next.tabs, ['dm:actor-x', 'dm:actor-y']);
      expect(next.active, 1);
    });

    test('a rail selection revives the conversation when none is hosted', () {
      final layout = ViewLayout(tabs: const ['browser']);
      final next = layout.openConversation('dm:actor-x');
      expect(next.tabs, ['browser', 'dm:actor-x']);
      expect(next.active, 1);
    });
  });

  group('close', () {
    test('closing a background tab keeps the active one', () {
      final layout = ViewLayout(tabs: const ['a', 'b', 'c']);
      final next = layout.close('b');
      expect(next.tabs, ['a', 'c']);
      expect(next.active, 0);
    });

    test('closing a tab before the active one shifts the focus', () {
      final layout = ViewLayout(tabs: const ['a', 'b', 'c'], active: 2);
      final next = layout.close('a');
      expect(next.tabs, ['b', 'c']);
      expect(next.active, 1);
    });

    test('closing the active tab focuses its neighbor', () {
      final layout = ViewLayout(tabs: const ['a', 'b', 'c'], active: 1);
      expect(layout.close('b').activeId, 'c');
      // The last tab slides back.
      final last = ViewLayout(tabs: const ['a', 'b', 'c'], active: 2);
      expect(last.close('c').activeId, 'b');
    });

    test('closing the LAST tab swaps the newtab surface in — the window '
        'keeps a page', () {
      final layout = ViewLayout(tabs: const ['a']);
      final next = layout.close('a');
      expect(next.tabs, [kNewTabSurfaceId]);
      expect(next.active, 0);
    });

    test('closing the lone PICKER is refused — nothing to swap into it', () {
      final layout = ViewLayout(tabs: const [kNewTabSurfaceId]);
      expect(layout.close(kNewTabSurfaceId), same(layout));
    });

    test('closing an unknown id changes nothing', () {
      final layout = ViewLayout(tabs: const ['a']);
      expect(layout.close('nope'), same(layout));
    });

    test('a PIN survives a tab close (closing removes the tab only)', () {
      final layout = ViewLayout(
        tabs: const ['a', 'b'],
        pinned: const ['a', 'b'],
        dockFocus: 'b',
      );
      final next = layout.close('b');
      expect(next.tabs, ['a']);
      expect(next.pinned, ['a', 'b']);
      expect(next.focusedDockId, 'b');
    });
  });

  group('newtab (the picker — the browser model)', () {
    test('openNewTab inserts the picker right of the active tab', () {
      final layout = ViewLayout(tabs: const ['a', 'b']);
      final next = layout.openNewTab();
      expect(next.tabs, ['a', kNewTabSurfaceId, 'b']);
      expect(next.active, 1);
    });

    test('an already-open picker just focuses (at most ONE exists)', () {
      final layout = ViewLayout(tabs: const ['a', kNewTabSurfaceId]);
      final next = layout.openNewTab();
      expect(next.tabs, ['a', kNewTabSurfaceId]);
      expect(next.active, 1);
    });

    test('a pick REPLACES the picker tab in place', () {
      final layout = ViewLayout(
        tabs: const ['a', kNewTabSurfaceId, 'b'],
        active: 1,
      );
      final next = layout.pick('c');
      expect(next.tabs, ['a', 'c', 'b']);
      expect(next.active, 1);
    });

    test('picking an already-open station focuses it; the picker closes', () {
      // The station sat after the picker: it shifts back one on close.
      final layout = ViewLayout(
        tabs: const [
          kConversationsSurfaceId,
          'browser',
          kNewTabSurfaceId,
        ],
        active: 2,
      );
      final next = layout.pick('browser');
      expect(next.tabs, [kConversationsSurfaceId, 'browser']);
      expect(next.active, 1);

      // The station sat before the picker: its index is unchanged.
      final leading = ViewLayout(tabs: const [kNewTabSurfaceId, 'browser']);
      final picked = leading.pick('browser');
      expect(picked.tabs, ['browser']);
      expect(picked.active, 0);
    });

    test('picking without a picker tab degrades to open', () {
      final layout = ViewLayout(tabs: const ['a']);
      final next = layout.pick('b');
      expect(next.tabs, ['a', 'b']);
      expect(next.active, 1);
    });

    test('picking the picker itself changes nothing', () {
      final layout = ViewLayout(tabs: const [kNewTabSurfaceId]);
      expect(layout.pick(kNewTabSurfaceId), same(layout));
    });

    test('a pick from the close-law strip lands on the destination alone', () {
      // ['newtab'] is the strip a last-close leaves; picking the
      // conversations face restores the default face exactly.
      final layout = ViewLayout(tabs: const [kNewTabSurfaceId]);
      final next = layout.pick(kConversationsSurfaceId);
      expect(next.tabs, [kConversationsSurfaceId]);
      expect(next.active, 0);
    });
  });

  group('move', () {
    test('reorders tabs and keeps the focused id focused', () {
      final layout = ViewLayout(tabs: const ['a', 'b', 'c']);
      final next = layout.move(0, 2);
      expect(next.tabs, ['b', 'c', 'a']);
      expect(next.activeId, 'a');
    });

    test('out-of-range targets clamp', () {
      final layout = ViewLayout(tabs: const ['a', 'b'], active: 1);
      expect(layout.move(1, 99).tabs, ['a', 'b']);
      expect(layout.move(1, -1).tabs, ['b', 'a']);
    });

    test('moving an unknown index changes nothing', () {
      final layout = ViewLayout(tabs: const ['a']);
      expect(layout.move(5, 0), same(layout));
    });
  });

  group('pin / unpin / focusDock (the dock — WAVE 5)', () {
    test('pin appends and focuses the dock; the tab stays open', () {
      final layout = ViewLayout(
        tabs: const [kConversationsSurfaceId, kFilesystemSurfaceId],
      );
      final next = layout.pin(kFilesystemSurfaceId);
      expect(next.pinned, [kPeopleSurfaceId, kFilesystemSurfaceId]);
      expect(next.focusedDockId, kFilesystemSurfaceId);
      // A view may be tab AND pin (Notion: page in peek AND in tab).
      expect(next.tabs, [kConversationsSurfaceId, kFilesystemSurfaceId]);
    });

    test('pinning an already-pinned view just focuses the dock', () {
      final layout = ViewLayout(
        tabs: const ['a'],
        pinned: const ['people', 'x'],
        dockFocus: 'people',
      );
      final next = layout.pin('x');
      expect(next.pinned, ['people', 'x']);
      expect(next.focusedDockId, 'x');
    });

    test('unpin removes the pin only; the focus falls to the first pin', () {
      final layout = ViewLayout(
        tabs: const ['a', 'b'],
        pinned: const ['people', 'b'],
        dockFocus: 'b',
      );
      final next = layout.unpin('b');
      expect(next.pinned, ['people']);
      expect(next.focusedDockId, 'people');
      // An open tab stays open.
      expect(next.tabs, ['a', 'b']);
    });

    test('unpinning an unpinned id changes nothing', () {
      final layout = ViewLayout();
      expect(layout.unpin('nope'), same(layout));
    });

    test('unpinning EVERYTHING empties the dock (no pins, no dock)', () {
      final layout = ViewLayout(tabs: const ['a']);
      final next = layout.unpin('people');
      expect(next.pinned, isEmpty);
      expect(next.focusedDockId, isNull);
    });

    test('focusDock moves the focus; an unpinned id is refused', () {
      final layout = ViewLayout(
        tabs: const ['a'],
        pinned: const ['people', 'terminal'],
        dockFocus: 'people',
      );
      final next = layout.focusDock('terminal');
      expect(next.focusedDockId, 'terminal');
      expect(layout.focusDock('nope'), same(layout));
      expect(layout.focusDock('people'), same(layout));
    });

    test('a stale dockFocus normalizes to the first pin', () {
      final layout = ViewLayout(
        tabs: const ['a'],
        pinned: const ['people', 'x'],
        dockFocus: 'ghost',
      );
      expect(layout.focusedDockId, 'people');
    });
  });

  group('persistence', () {
    test('JSON round-trip', () {
      final layout = ViewLayout(
        tabs: const ['dm:x', 'browser'],
        active: 1,
        pinned: const [kPeopleSurfaceId, 'x'],
        dockFocus: 'x',
      );
      expect(ViewLayout.fromJson(layout.toJson()), layout);
    });

    test('tolerant decode: junk decodes to the default layout', () {
      expect(ViewLayout.fromJson(null), ViewLayout());
      expect(ViewLayout.fromJson('nope'), ViewLayout());
      expect(ViewLayout.fromJson(const <String, Object?>{}), ViewLayout());
      expect(
        ViewLayout.fromJson(const <String, Object?>{'tabs': 'nope'}),
        ViewLayout(),
      );
      expect(
        ViewLayout.fromJson(const <String, Object?>{
          'tabs': [1, null, 'a', ''],
        }).tabs,
        ['a'],
      );
      // Pins filter to strings and dedupe; junk pins keep the default.
      expect(
        ViewLayout.fromJson(const <String, Object?>{
          'tabs': ['a'],
          'pinned': ['people', 3, 'people'],
        }).pinned,
        ['people'],
      );
    });

    test('a LONE newtab tab never survives a restart (session chrome)', () {
      expect(
        ViewLayout.fromJson(const <String, Object?>{
          'tabs': [kNewTabSurfaceId],
          'active': 0,
        }),
        ViewLayout(),
      );
      // Judge lone-ness after the decode's dedupe: the corrupt double
      // normalizes to the lone picker, so it remaps too.
      expect(
        ViewLayout.fromJson(const <String, Object?>{
          'tabs': [kNewTabSurfaceId, kNewTabSurfaceId],
          'active': 1,
        }),
        ViewLayout(),
      );
      // A picker among real tabs is live state and restores as-is.
      final multi = ViewLayout.fromJson(const <String, Object?>{
        'tabs': ['a', kNewTabSurfaceId],
        'active': 1,
      });
      expect(multi.tabs, ['a', kNewTabSurfaceId]);
      expect(multi.active, 1);
      // toJson keeps the real ids — the RESTORE is what remaps the lone
      // picker (the persisted JSON never lies while the session lives).
      expect(
        ViewLayout(tabs: const [kNewTabSurfaceId]).toJson(),
        <String, Object?>{
          'tabs': [kNewTabSurfaceId],
          'active': 0,
          'pinned': [kPeopleSurfaceId],
          'dockFocus': kPeopleSurfaceId,
        },
      );
    });

    test('the retired shell.tabs.v1 shape decodes as a v2 layout with '
        'the default People pin (the ONE-TIME migration input)', () {
      final migrated = ViewLayout.fromJson(const <String, Object?>{
        'tabs': [kConversationsSurfaceId, kInspectorSurfaceId],
        'active': 1,
      });
      expect(migrated.tabs, [kConversationsSurfaceId, kInspectorSurfaceId]);
      expect(migrated.active, 1);
      expect(migrated.pinned, [kPeopleSurfaceId]);
      expect(migrated.focusedDockId, kPeopleSurfaceId);
    });
  });

  group('legacyPaneTreeSurfaceIds (the one-time migration input)', () {
    test('a two-leaf split flattens in document order', () {
      final ids = legacyPaneTreeSurfaceIds(<String, Object?>{
        't': 'split',
        'axis': 'horizontal',
        'ratio': 0.5,
        'children': [
          {
            't': 'leaf',
            'surfaceId': 'inspector',
            'params': <String, Object?>{},
          },
          {
            't': 'leaf',
            'surfaceId': kConversationsSurfaceId,
            'params': <String, Object?>{},
          },
        ],
      });
      // Conversations leads the strip regardless of tree order.
      expect(ids, [kConversationsSurfaceId, 'inspector']);
    });

    test('a nested stack/split tree flattens depth-first, deduped', () {
      final ids = legacyPaneTreeSurfaceIds(<String, Object?>{
        't': 'split',
        'children': [
          {'t': 'leaf', 'surfaceId': 'browser'},
          {
            't': 'stack',
            'children': [
              {'t': 'leaf', 'surfaceId': 'browser'},
              {'t': 'leaf', 'surfaceId': 'dm:x'},
            ],
          },
        ],
      });
      expect(ids, ['browser', 'dm:x']);
    });

    test('junk decodes to an empty list (the caller keeps the default)', () {
      expect(legacyPaneTreeSurfaceIds(null), isEmpty);
      expect(legacyPaneTreeSurfaceIds('nope'), isEmpty);
      expect(legacyPaneTreeSurfaceIds(<String, Object?>{}), isEmpty);
    });
  });
}
