import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/surfaces.dart';

/// Phase 1a gate (docs/design/shell-redesign-rail-views-tabs-2026-11-05.md):
/// the per-view tab model — each view owns a Safari-like strip, the v2/v1
/// global-bar blob migrates without losing a tab or a pin.
void main() {
  group('ShellLayout defaults', () {
    test('the default layout hosts conversations with its world face', () {
      final layout = ShellLayout.defaultLayout();
      expect(layout.activeView, kConversationsSurfaceId);
      expect(layout.activeSurfaceId, kConversationsSurfaceId);
      expect(layout.tabsOf(kPeopleSurfaceId), [kPeopleSurfaceId]);
    });

    test('showView opens a default strip for a view with no history', () {
      final layout = ShellLayout.defaultLayout().showView(kBoardsSurfaceId);
      expect(layout.activeView, kBoardsSurfaceId);
      expect(layout.activeSurfaceId, kBoardsSurfaceId);
      // The conversations strip survives the switch.
      expect(layout.tabsOf(kConversationsSurfaceId), [
        kConversationsSurfaceId,
      ]);
    });
  });

  group('per-view tab operations', () {
    test('openTab inserts right of the focused tab and hosts the view', () {
      final layout = ShellLayout.defaultLayout()
          .openTab(kConversationsSurfaceId, 'dm:scout')
          .openTab(kConversationsSurfaceId, 'dm:weaver');
      expect(layout.tabsOf(kConversationsSurfaceId), [
        kConversationsSurfaceId,
        'dm:scout',
        'dm:weaver',
      ]);
      expect(layout.activeSurfaceId, 'dm:weaver');
    });

    test('openTab on an open id focuses it instead of duplicating', () {
      final layout = ShellLayout.defaultLayout()
          .openTab(kConversationsSurfaceId, 'dm:scout')
          .openTab(kConversationsSurfaceId, kConversationsSurfaceId)
          .openTab(kConversationsSurfaceId, 'dm:scout');
      expect(layout.tabsOf(kConversationsSurfaceId), [
        kConversationsSurfaceId,
        'dm:scout',
      ]);
      expect(layout.activeSurfaceId, 'dm:scout');
    });

    test('closeTab focuses the neighbor and never empties a strip', () {
      var layout = ShellLayout.defaultLayout()
          .openTab(kBoardsSurfaceId, 'board:a')
          .openTab(kBoardsSurfaceId, 'board:b');
      expect(layout.activeSurfaceId, 'board:b');
      layout = layout.closeTab(kBoardsSurfaceId, 'board:b');
      expect(layout.activeSurfaceId, 'board:a');
      layout = layout.closeTab(kBoardsSurfaceId, 'board:a');
      // The view's own default tab survives; closing IT swaps the picker.
      expect(layout.tabsOf(kBoardsSurfaceId), [kBoardsSurfaceId]);
      layout = layout.closeTab(kBoardsSurfaceId, kBoardsSurfaceId);
      expect(layout.tabsOf(kBoardsSurfaceId), [kNewTabSurfaceId]);
      // The lone picker is refused.
      expect(
        layout.closeTab(kBoardsSurfaceId, kNewTabSurfaceId),
        layout,
      );
    });

    test('moveTab keeps the focused id focused', () {
      final layout = ShellLayout.defaultLayout()
          .openTab(kConversationsSurfaceId, 'dm:scout')
          .openTab(kConversationsSurfaceId, 'dm:weaver')
          .moveTab(kConversationsSurfaceId, 2, 0);
      expect(layout.tabsOf(kConversationsSurfaceId), [
        'dm:weaver',
        kConversationsSurfaceId,
        'dm:scout',
      ]);
      expect(layout.activeSurfaceId, 'dm:weaver');
    });

    test('pick replaces the picker tab in place', () {
      final layout = ShellLayout.defaultLayout()
          .openNewTab()
          .pick(kInspectorSurfaceId);
      expect(layout.tabsOf(kConversationsSurfaceId), [
        kConversationsSurfaceId,
        kInspectorSurfaceId,
      ]);
      expect(layout.activeSurfaceId, kInspectorSurfaceId);
    });

    test('pick on an already-open tab closes the picker and focuses it', () {
      final layout = ShellLayout.defaultLayout()
          .openNewTab()
          .pick(kConversationsSurfaceId);
      expect(layout.tabsOf(kConversationsSurfaceId), [
        kConversationsSurfaceId,
      ]);
      expect(layout.activeSurfaceId, kConversationsSurfaceId);
    });
  });

  group('conversation slot law', () {
    test('conversation ids reuse the one slot in place', () {
      final layout = ShellLayout.defaultLayout()
          .openConversation('dm:scout')
          .openConversation('channel:lab');
      expect(layout.tabsOf(kConversationsSurfaceId), ['channel:lab']);
      expect(layout.activeSurfaceId, 'channel:lab');
    });

    test('forceNew gives the id its own tab next to the slot', () {
      final layout = ShellLayout.defaultLayout()
          .openConversation('dm:scout')
          .openConversation('dm:weaver', forceNew: true);
      expect(layout.tabsOf(kConversationsSurfaceId), [
        'dm:scout',
        'dm:weaver',
      ]);
    });
  });

  group('v2/v1 migration', () {
    test('the global bar becomes per-view strips, pins become tabs', () {
      final layout = ShellLayout.fromJson(<String, Object?>{
        'tabs': <String>[kConversationsSurfaceId, kBoardsSurfaceId, 'dm:scout'],
        'active': 2,
        'pinned': <String>[kPeopleSurfaceId, kInspectorSurfaceId],
        'dockFocus': kInspectorSurfaceId,
      });
      expect(layout.activeView, kConversationsSurfaceId);
      expect(layout.activeSurfaceId, 'dm:scout');
      expect(layout.tabsOf(kConversationsSurfaceId), [
        kConversationsSurfaceId,
        'dm:scout',
      ]);
      expect(layout.tabsOf(kBoardsSurfaceId), [kBoardsSurfaceId]);
      expect(layout.tabsOf(kPeopleSurfaceId), [kPeopleSurfaceId]);
      expect(layout.tabsOf(kInspectorSurfaceId), [kInspectorSurfaceId]);
    });

    test('a lone picker tab restores to the default layout', () {
      final layout = ShellLayout.fromJson(<String, Object?>{
        'tabs': <String>[kNewTabSurfaceId],
        'active': 0,
      });
      expect(layout, ShellLayout.defaultLayout());
    });

    test('v3 round-trips through json', () {
      final layout = ShellLayout.defaultLayout()
          .openTab(kBoardsSurfaceId, 'board:a');
      final decoded = ShellLayout.fromJson(layout.toJson());
      expect(decoded, layout);
    });

    test('garbage decodes to the default layout', () {
      expect(ShellLayout.fromJson('nope'), ShellLayout.defaultLayout());
      expect(ShellLayout.fromJson(null), ShellLayout.defaultLayout());
    });
  });
}
