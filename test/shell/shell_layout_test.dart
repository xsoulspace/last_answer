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

    test('closing a trailing group\'s last tab removes the group', () {
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

  group('per-group history (the strip\'s ‹ ›)', () {
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
      final layout = ShellLayout.fromJson(<String, Object?>{
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
      final layout = ShellLayout.fromJson(<String, Object?>{
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
      final layout = ShellLayout.fromJson(<String, Object?>{
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
      final layout = ShellLayout.fromJson(<String, Object?>{
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
      expect((blob['groups'] as List), hasLength(2));
    });

    test('garbage decodes to the default layout', () {
      expect(ShellLayout.fromJson('nope'), ShellLayout.defaultLayout());
      expect(ShellLayout.fromJson(null), ShellLayout.defaultLayout());
      expect(
        ShellLayout.fromJson(<String, Object?>{'v': 4, 'groups': <Object?>[]}),
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
