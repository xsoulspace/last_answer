import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// DESIGN.md v2 tab-law gate: the pane-group layout model — groups own
/// strips, splits move the active tab into a new group, folds merge
/// back, tabs are instances, each group keeps a back/forward MRU, and
/// the v3/v2/v1 blobs migrate into ONE group without losing a tab.
void main() {
  group('ShellLayout defaults', () {
    test('the default layout is ONE group on the world face', () {
      final layout = ShellLayout.defaultLayout();
      expect(layout.groups, hasLength(1));
      expect(layout.active, 0);
      expect(layout.activeSurfaceId, kConversationsSurfaceId);
      expect(layout.isSplit, isFalse);
    });

    test('an empty group list normalizes to the default', () {
      expect(ShellLayout(), ShellLayout.defaultLayout());
    });
  });

  group('tab operations', () {
    test('openTab inserts right of the focused tab', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('dm:weaver');
      expect(layout.groups[0].tabs, [
        kConversationsSurfaceId,
        'dm:scout',
        'dm:weaver',
      ]);
      expect(layout.activeSurfaceId, 'dm:weaver');
    });

    test('openTab on an open id focuses it instead of duplicating', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab(kConversationsSurfaceId)
          .openTab('dm:scout');
      expect(layout.groups[0].tabs, [kConversationsSurfaceId, 'dm:scout']);
      expect(layout.activeSurfaceId, 'dm:scout');
    });

    test('closeTab focuses the neighbor; the sole group lands on the '
        'world face (the front door, never empty)', () {
      var layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('dm:weaver');
      layout = layout.closeTab('dm:weaver');
      expect(layout.activeSurfaceId, 'dm:scout');
      layout = layout.closeTab('dm:scout');
      expect(layout.groups[0].tabs, [kConversationsSurfaceId]);
      // Closing the world face itself is refused (a strip never empties).
      expect(layout.closeTab(kConversationsSurfaceId), layout);
    });

    test('moveTab keeps the focused id focused', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('dm:weaver')
          .moveTab(0, 2, 0);
      expect(layout.groups[0].tabs, [
        'dm:weaver',
        kConversationsSurfaceId,
        'dm:scout',
      ]);
      expect(layout.activeSurfaceId, 'dm:weaver');
    });
  });

  group('moveTabTo (the native-drag law)', () {
    test('same-group reorder keeps the focused id focused; the default '
        'at is the end of the strip', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('dm:weaver');
      final reordered = layout.moveTabTo(tabId: 'dm:weaver', group: 0, at: 0);
      expect(reordered.groups[0].tabs, [
        'dm:weaver',
        kConversationsSurfaceId,
        'dm:scout',
      ]);
      expect(reordered.activeSurfaceId, 'dm:weaver');

      final toEnd = layout.moveTabTo(tabId: kConversationsSurfaceId, group: 0);
      expect(toEnd.groups[0].tabs, [
        'dm:scout',
        'dm:weaver',
        kConversationsSurfaceId,
      ]);
      expect(toEnd.activeSurfaceId, 'dm:weaver');
    });

    test('a cross-group move: the tab LEAVES the source, takes focus in '
        'the target and the target group becomes active', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .split();
      final moved = layout.moveTabTo(tabId: 'dm:scout', group: 1);
      expect(moved.groups[0].tabs, [kConversationsSurfaceId]);
      expect(moved.groups[1].tabs, ['doc:42', 'dm:scout']);
      expect(moved.active, 1);
      expect(moved.activeSurfaceId, 'dm:scout');
    });

    test('MRU coherence: the source forgets the moved tab, the target '
        'remembers it', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .split();
      final moved = layout.moveTabTo(tabId: 'dm:scout', group: 1);
      // The source's back can never resurrect the tab that left.
      expect(moved.groups[0].canBack, isFalse);
      // The target remembers: back from the landed tab steps to the
      // group's previous focus.
      expect(moved.back().activeSurfaceId, 'doc:42');
    });

    test('an emptied source is removed and the target index shifts down '
        '(the closeTab law)', () {
      final layout = ShellLayout(
        groups: <ViewState>[
          ViewState(tabs: const <String>['a']),
          ViewState(tabs: const <String>['b']),
          ViewState(tabs: const <String>['c']),
        ],
        active: 1,
      );
      final moved = layout.moveTabTo(tabId: 'a', group: 2);
      expect(moved.groups, hasLength(2));
      expect(moved.groups[0].tabs, <String>['b']);
      expect(moved.groups[1].tabs, <String>['c', 'a']);
      expect(moved.active, 1, reason: 'the target moved down with the '
          'removed source');
      expect(moved.activeSurfaceId, 'a');
    });

    test('the sole tab of the SOLE group has nowhere to go: every other '
        'index is out of range (callers split instead)', () {
      final sole = ShellLayout(
        groups: <ViewState>[ViewState(tabs: const <String>['dm:scout'])],
      );
      expect(sole.moveTabTo(tabId: 'dm:scout', group: 1), sole);
      final face = ShellLayout.defaultLayout();
      expect(face.moveTabTo(tabId: kConversationsSurfaceId, group: 1), face);
    });

    test('an unknown id or an out-of-range group changes nothing', () {
      final layout = ShellLayout.defaultLayout().openTab('dm:scout');
      expect(layout.moveTabTo(tabId: 'ghost', group: 0), layout);
      expect(layout.moveTabTo(tabId: 'dm:scout', group: 7), layout);
      expect(layout.moveTabTo(tabId: 'dm:scout', group: -1), layout);
    });
  });

  group('splits: pane groups (VS Code anatomy)', () {
    test('split MOVES the active tab into a new group to the right', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .split();
      expect(layout.groups, hasLength(2));
      expect(layout.active, 1, reason: 'the new pane takes focus');
      expect(layout.groups[1].tabs, ['doc:42']);
      expect(layout.groups[0].tabs, [kConversationsSurfaceId, 'dm:scout']);
    });

    test('splitting a lone tab refills the source with the world face', () {
      final layout = ShellLayout.defaultLayout().openTab('dm:scout').split();
      expect(layout.groups[0].tabs, [kConversationsSurfaceId]);
      expect(layout.groups[1].tabs, ['dm:scout']);
      expect(layout.activeSurfaceId, 'dm:scout');
    });

    test('splitting the lone world face is refused (nothing honest to '
        'show beside itself)', () {
      final layout = ShellLayout.defaultLayout();
      expect(layout.split(), layout);
    });

    test('fold merges the group back into its left neighbour, focus '
        'follows the folded tab', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .split()
          .fold();
      expect(layout.groups, hasLength(1));
      expect(layout.groups[0].tabs, [
        kConversationsSurfaceId,
        'dm:scout',
        'doc:42',
      ]);
      expect(layout.activeSurfaceId, 'doc:42');
    });

    test("closing a trailing group's last tab removes the group", () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .split()
          .closeTab('doc:42');
      expect(layout.groups, hasLength(1));
      expect(layout.active, 0);
    });

    test('an open id focuses WHERE IT LIVES (ids unique across groups)', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .split()
          .openTab('dm:scout');
      expect(layout.groups, hasLength(2));
      expect(layout.active, 0);
      expect(layout.activeSurfaceId, 'dm:scout');
    });
  });

  group('splitTabAt (the native-drag split law: the dashed pane edge)', () {
    test('after: the new group lands to the RIGHT of index, focused and '
        'active; the source keeps its rest with the neighbour focused', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42');
      final split = layout.splitTabAt(
        tabId: 'dm:scout',
        index: 0,
        after: true,
      );
      expect(split.groups, hasLength(2));
      expect(split.groups[0].tabs, [kConversationsSurfaceId, 'doc:42']);
      expect(split.groups[0].activeId, 'doc:42');
      expect(split.groups[1].tabs, ['dm:scout']);
      expect(split.active, 1);
      expect(split.activeSurfaceId, 'dm:scout');
      // The source's MRU forgot the tab that left (back skips it).
      expect(split.groups[0].back().activeId, kConversationsSurfaceId);
    });

    test('before: index 0 puts the new group FIRST', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42');
      final split = layout.splitTabAt(
        tabId: 'doc:42',
        index: 0,
        after: false,
      );
      expect(split.groups[0].tabs, ['doc:42']);
      expect(split.groups[1].tabs, [kConversationsSurfaceId, 'dm:scout']);
      expect(split.groups[1].activeId, 'dm:scout');
      expect(split.active, 0);
    });

    test('a middle drop: two groups become three, the dragged tab alone '
        'in the middle', () {
      final layout = ShellLayout(
        groups: <ViewState>[
          ViewState(tabs: const <String>['a', 'b']),
          ViewState(tabs: const <String>['c']),
        ],
      );
      final split = layout.splitTabAt(tabId: 'b', index: 0, after: true);
      expect(split.groups, hasLength(3));
      expect(split.groups[0].tabs, <String>['a']);
      expect(split.groups[1].tabs, <String>['b']);
      expect(split.groups[2].tabs, <String>['c']);
      expect(split.active, 1);
    });

    test('the emptied SOLE group refills with the world face (the front '
        'door, exactly like split)', () {
      final layout = ShellLayout(
        groups: <ViewState>[ViewState(tabs: const <String>['dm:scout'])],
      );
      final split = layout.splitTabAt(
        tabId: 'dm:scout',
        index: 0,
        after: true,
      );
      expect(split.groups[0].tabs, [kConversationsSurfaceId]);
      expect(split.groups[1].tabs, ['dm:scout']);
      expect(split.active, 1);
    });

    test('an emptied source is REMOVED when another group survives, and '
        'the insert position shifts down past the removal', () {
      final layout = ShellLayout(
        groups: <ViewState>[
          ViewState(tabs: const <String>['a']),
          ViewState(tabs: const <String>['b', 'c']),
        ],
      );
      // The last group's RIGHT edge: the new group lands at the end.
      final right = layout.splitTabAt(tabId: 'a', index: 1, after: true);
      expect(right.groups, hasLength(2));
      expect(right.groups[0].tabs, <String>['b', 'c']);
      expect(right.groups[1].tabs, <String>['a']);
      expect(right.active, 1);
      // The last group's LEFT edge: the position shifts down with the
      // removed source — the new group lands first.
      final left = layout.splitTabAt(tabId: 'a', index: 1, after: false);
      expect(left.groups, hasLength(2));
      expect(left.groups[0].tabs, <String>['a']);
      expect(left.groups[1].tabs, <String>['b', 'c']);
      expect(left.active, 0);
    });

    test('the sole conversations tab of the sole group is refused '
        '(nothing honest to show beside itself)', () {
      final sole = ShellLayout.defaultLayout();
      expect(
        sole.splitTabAt(tabId: kConversationsSurfaceId, index: 0, after: true),
        sole,
      );
      expect(
        sole.splitTabAt(
          tabId: kConversationsSurfaceId,
          index: 0,
          after: false,
        ),
        sole,
      );
    });

    test('an out-of-range index or an unknown id is refused', () {
      final layout = ShellLayout.defaultLayout().openTab('dm:scout');
      expect(
        layout.splitTabAt(tabId: 'dm:scout', index: 1, after: true),
        layout,
      );
      expect(
        layout.splitTabAt(tabId: 'dm:scout', index: -1, after: false),
        layout,
      );
      expect(layout.splitTabAt(tabId: 'ghost', index: 0, after: true), layout);
    });
  });

  group('instances (the tab law: same kind, N times)', () {
    test('nextInstanceId scans the open tabs and counts the bare kind', () {
      var layout = ShellLayout.defaultLayout();
      expect(layout.nextInstanceId(kBrowserSurfaceId), 'browser:2');
      layout = layout.openTab('browser:2');
      expect(layout.nextInstanceId(kBrowserSurfaceId), 'browser:3');
      layout = layout.openTab('browser:7');
      expect(layout.nextInstanceId(kBrowserSurfaceId), 'browser:8');
    });

    test('two instances of one kind live side by side', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('browser:2')
          .openTab('browser:3')
          .split();
      expect(layout.groups[1].tabs, ['browser:3']);
      expect(layout.groups[0].tabs, contains('browser:2'));
    });
  });

  group("per-group history (the strip's ‹ ›)", () {
    test('back and forward walk the focus MRU', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42');
      expect(layout.activeSurfaceId, 'doc:42');
      final back1 = layout.back();
      expect(back1.activeSurfaceId, 'dm:scout');
      final back2 = back1.back();
      expect(back2.activeSurfaceId, kConversationsSurfaceId);
      // The floor: no further back.
      expect(back2.back(), back2);
      expect(back2.activeGroup.canBack, isFalse);
      final fwd = back2.forward();
      expect(fwd.activeSurfaceId, 'dm:scout');
      expect(layout.forward(), layout, reason: 'at the head: no forward');
    });

    test('closed tabs are skipped, never resurrected', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .closeTab('dm:scout');
      // hist: conversations → doc:42 (scout pruned); back skips it.
      expect(layout.activeSurfaceId, 'doc:42');
      expect(layout.back().activeSurfaceId, kConversationsSurfaceId);
    });
  });

  group('migration', () {
    test('a v3 per-view blob flattens into ONE group, active view first', () {
      final layout = ShellLayout.fromJson(const <String, Object?>{
        'v': 3,
        'activeView': kBoardsSurfaceId,
        'views': <String, Object?>{
          kConversationsSurfaceId: <String, Object?>{
            'tabs': <String>[kConversationsSurfaceId, 'dm:scout'],
            'active': 1,
          },
          kBoardsSurfaceId: <String, Object?>{
            'tabs': <String>[kBoardsSurfaceId, 'board:a'],
            'active': 0,
          },
          kPeopleSurfaceId: <String, Object?>{
            'tabs': <String>[kPeopleSurfaceId],
            'active': 0,
          },
        },
      });
      expect(layout.groups, hasLength(1));
      // The active view's strip leads; its focused tab keeps focus.
      expect(layout.groups[0].tabs, [
        kBoardsSurfaceId,
        'board:a',
        kConversationsSurfaceId,
        'dm:scout',
        kPeopleSurfaceId,
      ]);
      expect(layout.activeSurfaceId, kBoardsSurfaceId);
    });

    test('a v3 picker tab is session chrome — not restored', () {
      final layout = ShellLayout.fromJson(const <String, Object?>{
        'v': 3,
        'activeView': kConversationsSurfaceId,
        'views': <String, Object?>{
          kConversationsSurfaceId: <String, Object?>{
            'tabs': <String>['dm:scout', kNewTabSurfaceId],
            'active': 1,
          },
        },
      });
      expect(layout.groups[0].tabs, ['dm:scout']);
    });

    test('the v2 global bar + pins flatten into the one group', () {
      final layout = ShellLayout.fromJson(const <String, Object?>{
        'tabs': <String>[kConversationsSurfaceId, kBoardsSurfaceId, 'dm:scout'],
        'active': 2,
        'pinned': <String>[kPeopleSurfaceId, kInspectorSurfaceId],
        'dockFocus': kInspectorSurfaceId,
      });
      expect(layout.groups, hasLength(1));
      expect(layout.groups[0].tabs, [
        kConversationsSurfaceId,
        kBoardsSurfaceId,
        'dm:scout',
        kPeopleSurfaceId,
        kInspectorSurfaceId,
      ]);
      expect(layout.activeSurfaceId, 'dm:scout');
    });

    test('a lone picker blob restores to the default layout', () {
      final layout = ShellLayout.fromJson(const <String, Object?>{
        'tabs': <String>[kNewTabSurfaceId],
        'active': 0,
      });
      expect(layout, ShellLayout.defaultLayout());
    });

    test('v4 round-trips through json (history is session-scoped and '
        'stays out of the blob)', () {
      final layout = ShellLayout.defaultLayout()
          .openTab('dm:scout')
          .openTab('doc:42')
          .split();
      final decoded = ShellLayout.fromJson(layout.toJson());
      expect(decoded, layout);
      final blob = layout.toJson();
      expect(blob['v'], 4);
      expect(blob['groups']! as List, hasLength(2));
    });

    test('garbage decodes to the default layout', () {
      expect(ShellLayout.fromJson('nope'), ShellLayout.defaultLayout());
      expect(ShellLayout.fromJson(null), ShellLayout.defaultLayout());
      expect(
        ShellLayout.fromJson(
          const <String, Object?>{'v': 4, 'groups': <Object?>[]},
        ),
        ShellLayout.defaultLayout(),
      );
    });
  });

  group('kind vocabulary', () {
    test('content ids fold into their kind; static ids are their own', () {
      expect(kindOfSurfaceId('dm:scout'), kConversationsSurfaceId);
      expect(kindOfSurfaceId('channel:lab'), kConversationsSurfaceId);
      expect(kindOfSurfaceId(kConversationsSurfaceId), kConversationsSurfaceId);
      expect(kindOfSurfaceId('doc:42'), kDocumentsSurfaceId);
      expect(kindOfSurfaceId('browser:3'), kBrowserSurfaceId);
      expect(kindOfSurfaceId(kBrowserSurfaceId), kBrowserSurfaceId);
      expect(kindOfSurfaceId(kBoardsSurfaceId), kBoardsSurfaceId);
    });
  });
}
