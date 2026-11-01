// The center tab strip's model law: unique ids, one conversation slot
// (dm:/channel: reuse it in place — the Discord flow), the last tab is
// immortal, and the persisted JSON decodes tolerantly. The legacy
// pane-tree flatten (the one-time migration's input) is covered here
// too.
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';

import 'package:lastanswer/shell/center_tabs.dart';

import 'package:lastanswer/shell/surfaces.dart';

void main() {
  group('normalization', () {
    test('the default strip is the world conversations surface', () {
      final tabs = CenterTabs();
      expect(tabs.surfaceIds, [kConversationsSurfaceId]);
      expect(tabs.active, 0);
      expect(tabs.activeId, kConversationsSurfaceId);
    });

    test('duplicate ids keep their first occurrence', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b', 'a'], active: 2);
      expect(tabs.surfaceIds, ['a', 'b']);
      // The surviving ids are [a, b]; the out-of-range focus clamps.
      expect(tabs.active, 1);
    });

    test('an empty strip falls back to conversations', () {
      final tabs = CenterTabs(surfaceIds: const []);
      expect(tabs.surfaceIds, [kConversationsSurfaceId]);
      expect(tabs.active, 0);
    });

    test('an out-of-range active index clamps', () {
      expect(CenterTabs(surfaceIds: const ['a', 'b'], active: 9).active, 1);
      expect(CenterTabs(surfaceIds: const ['a', 'b'], active: -3).active, 0);
    });

    test('value equality: ids and active index', () {
      expect(
        CenterTabs(surfaceIds: const ['a']),
        CenterTabs(surfaceIds: const ['a']),
      );
      expect(
        CenterTabs(surfaceIds: const ['a']),
        isNot(CenterTabs(surfaceIds: const ['b'])),
      );
      expect(
        CenterTabs(surfaceIds: const ['a', 'b'], active: 1),
        isNot(CenterTabs(surfaceIds: const ['a', 'b'])),
      );
    });
  });

  group('open (strip taps)', () {
    test('a new station opens right of the active tab and focuses it', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b']);
      final next = tabs.open('c');
      expect(next.surfaceIds, ['a', 'c', 'b']);
      expect(next.active, 1);
    });

    test('an already-open station just focuses', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b']);
      expect(tabs.open('b').surfaceIds, ['a', 'b']);
      expect(tabs.open('b').active, 1);
    });
  });

  group('openConversation (the rail flow)', () {
    test('a rail selection replaces the slot id in place', () {
      final tabs = CenterTabs(surfaceIds: const [
        kConversationsSurfaceId,
        'browser',
      ]);
      final next = tabs.openConversation('dm:actor-x');
      expect(next.surfaceIds, ['dm:actor-x', 'browser']);
      expect(next.active, 0);
    });

    test('selecting another conversation keeps the count, focuses it', () {
      // The rail click SHOWS the conversation (Discord flow): the slot
      // keeps its position and takes the focus, the tab count is
      // unchanged.
      final tabs = CenterTabs(
        surfaceIds: const ['dm:actor-x', 'browser', 'inspector'],
        active: 2,
      );
      final next = tabs.openConversation('channel:c1');
      expect(next.surfaceIds, ['channel:c1', 'browser', 'inspector']);
      expect(next.active, 0);
    });

    test('re-selecting the focused conversation is a no-op', () {
      final tabs = CenterTabs(surfaceIds: const ['dm:actor-x', 'browser']);
      expect(tabs.openConversation('dm:actor-x'), same(tabs));
    });

    test('an ordinary rail selection never destroys explicit tabs', () {
      // The dm:actor-y tab was spawned explicitly (⌘-click intent); a
      // plain rail selection of dm:actor-x focuses the slot and leaves
      // the explicit tab alone.
      final tabs = CenterTabs(
        surfaceIds: const ['dm:actor-x', 'dm:actor-y', 'browser'],
        active: 1,
      );
      final next = tabs.openConversation('dm:actor-x');
      expect(next.surfaceIds, ['dm:actor-x', 'dm:actor-y', 'browser']);
      expect(next.active, 0);
    });

    test('forceNew spawns a dedicated tab next to the slot', () {
      final tabs = CenterTabs(surfaceIds: const ['dm:actor-x', 'browser']);
      final next = tabs.openConversation('dm:actor-y', forceNew: true);
      expect(next.surfaceIds, ['dm:actor-x', 'dm:actor-y', 'browser']);
      expect(next.active, 1);
    });

    test('forceNew on an open conversation focuses it instead', () {
      final tabs = CenterTabs(
        surfaceIds: const ['dm:actor-x', 'dm:actor-y'],
      );
      final next = tabs.openConversation('dm:actor-y', forceNew: true);
      expect(next.surfaceIds, ['dm:actor-x', 'dm:actor-y']);
      expect(next.active, 1);
    });

    test('a rail selection revives the conversation when none is hosted', () {
      final tabs = CenterTabs(surfaceIds: const ['browser']);
      final next = tabs.openConversation('dm:actor-x');
      expect(next.surfaceIds, ['browser', 'dm:actor-x']);
      expect(next.active, 1);
    });
  });

  group('close', () {
    test('closing a background tab keeps the active one', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b', 'c']);
      final next = tabs.close('b');
      expect(next.surfaceIds, ['a', 'c']);
      expect(next.active, 0);
    });

    test('closing a tab before the active one shifts the focus', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b', 'c'], active: 2);
      final next = tabs.close('a');
      expect(next.surfaceIds, ['b', 'c']);
      expect(next.active, 1);
    });

    test('closing the active tab focuses its neighbor', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b', 'c'], active: 1);
      expect(tabs.close('b').activeId, 'c');
      // The last tab slides back.
      final last = CenterTabs(surfaceIds: const ['a', 'b', 'c'], active: 2);
      expect(last.close('c').activeId, 'b');
    });

    test('closing the LAST tab swaps the newtab surface in — the window '
        'keeps a page', () {
      final tabs = CenterTabs();
      final next = tabs.close(kConversationsSurfaceId);
      expect(next.surfaceIds, [kNewTabSurfaceId]);
      expect(next.active, 0);
    });

    test('closing the lone PICKER is refused — nothing to swap into it', () {
      final tabs = CenterTabs(surfaceIds: const [kNewTabSurfaceId]);
      expect(tabs.close(kNewTabSurfaceId), same(tabs));
    });

    test('closing an unknown id changes nothing', () {
      final tabs = CenterTabs(surfaceIds: const ['a']);
      expect(tabs.close('nope'), same(tabs));
    });
  });

  group('newtab (the picker — the browser model)', () {
    test('openNewTab inserts the picker right of the active tab', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b']);
      final next = tabs.openNewTab();
      expect(next.surfaceIds, ['a', kNewTabSurfaceId, 'b']);
      expect(next.active, 1);
    });

    test('an already-open picker just focuses (at most ONE exists)', () {
      final tabs = CenterTabs(surfaceIds: const ['a', kNewTabSurfaceId]);
      final next = tabs.openNewTab();
      expect(next.surfaceIds, ['a', kNewTabSurfaceId]);
      expect(next.active, 1);
    });

    test('a pick REPLACES the picker tab in place', () {
      final tabs = CenterTabs(
        surfaceIds: const ['a', kNewTabSurfaceId, 'b'],
        active: 1,
      );
      final next = tabs.pick('c');
      expect(next.surfaceIds, ['a', 'c', 'b']);
      expect(next.active, 1);
    });

    test('picking an already-open station focuses it; the picker closes', () {
      // The station sat after the picker: it shifts back one on close.
      final tabs = CenterTabs(
        surfaceIds: const [
          kConversationsSurfaceId,
          'browser',
          kNewTabSurfaceId,
        ],
        active: 2,
      );
      final next = tabs.pick('browser');
      expect(next.surfaceIds, [kConversationsSurfaceId, 'browser']);
      expect(next.active, 1);

      // The station sat before the picker: its index is unchanged.
      final leading = CenterTabs(
        surfaceIds: const [kNewTabSurfaceId, 'browser'],
      );
      final picked = leading.pick('browser');
      expect(picked.surfaceIds, ['browser']);
      expect(picked.active, 0);
    });

    test('picking without a picker tab degrades to open', () {
      final tabs = CenterTabs(surfaceIds: const ['a']);
      final next = tabs.pick('b');
      expect(next.surfaceIds, ['a', 'b']);
      expect(next.active, 1);
    });

    test('picking the picker itself changes nothing', () {
      final tabs = CenterTabs(surfaceIds: const [kNewTabSurfaceId]);
      expect(tabs.pick(kNewTabSurfaceId), same(tabs));
    });

    test('a pick from the close-law strip lands on the destination alone', () {
      // ['newtab'] is the strip a last-close leaves; picking the
      // conversations face restores the default face exactly.
      final tabs = CenterTabs(surfaceIds: const [kNewTabSurfaceId]);
      final next = tabs.pick(kConversationsSurfaceId);
      expect(next.surfaceIds, [kConversationsSurfaceId]);
      expect(next.active, 0);
    });
  });

  group('move', () {
    test('reorders tabs and keeps the focused id focused', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b', 'c']);
      final next = tabs.move(0, 2);
      expect(next.surfaceIds, ['b', 'c', 'a']);
      expect(next.activeId, 'a');
    });

    test('out-of-range targets clamp', () {
      final tabs = CenterTabs(surfaceIds: const ['a', 'b'], active: 1);
      expect(tabs.move(1, 99).surfaceIds, ['a', 'b']);
      expect(tabs.move(1, -1).surfaceIds, ['b', 'a']);
    });

    test('moving an unknown index changes nothing', () {
      final tabs = CenterTabs(surfaceIds: const ['a']);
      expect(tabs.move(5, 0), same(tabs));
    });
  });

  group('persistence', () {
    test('JSON round-trip', () {
      final tabs = CenterTabs(
        surfaceIds: const ['dm:x', 'browser'],
        active: 1,
      );
      expect(CenterTabs.fromJson(tabs.toJson()), tabs);
    });

    test('tolerant decode: junk decodes to the default strip', () {
      expect(CenterTabs.fromJson(null), CenterTabs());
      expect(CenterTabs.fromJson('nope'), CenterTabs());
      expect(
        CenterTabs.fromJson(const <String, Object?>{}),
        CenterTabs(),
      );
      expect(
        CenterTabs.fromJson(
          const <String, Object?>{'tabs': 'nope'},
        ),
        CenterTabs(),
      );
      expect(
        CenterTabs.fromJson(const <String, Object?>{
          'tabs': [1, null, 'a', ''],
        }).surfaceIds,
        ['a'],
      );
    });

    test('a LONE newtab tab never survives a restart (session chrome)', () {
      expect(
        CenterTabs.fromJson(const <String, Object?>{
          'tabs': [kNewTabSurfaceId],
          'active': 0,
        }),
        CenterTabs(),
      );
      // Judge lone-ness after the decode's dedupe: the corrupt double
      // normalizes to the lone picker, so it remaps too.
      expect(
        CenterTabs.fromJson(const <String, Object?>{
          'tabs': [kNewTabSurfaceId, kNewTabSurfaceId],
          'active': 1,
        }),
        CenterTabs(),
      );
      // A picker among real tabs is live state and restores as-is.
      final multi = CenterTabs.fromJson(const <String, Object?>{
        'tabs': ['a', kNewTabSurfaceId],
        'active': 1,
      });
      expect(multi.surfaceIds, ['a', kNewTabSurfaceId]);
      expect(multi.active, 1);
      // toJson keeps the real ids — the RESTORE is what remaps the lone
      // picker (the persisted JSON never lies while the session lives).
      expect(
        CenterTabs(surfaceIds: const [kNewTabSurfaceId]).toJson(),
        <String, Object?>{
          'tabs': [kNewTabSurfaceId],
          'active': 0,
        },
      );
    });
  });

  group('conversation mapping', () {
    test('isConversationSurfaceId covers the slot vocabularies', () {
      expect(isConversationSurfaceId(kConversationsSurfaceId), isTrue);
      expect(isConversationSurfaceId('dm:actor-x'), isTrue);
      expect(isConversationSurfaceId('channel:c1'), isTrue);
      expect(isConversationSurfaceId('browser'), isFalse);
      expect(isConversationSurfaceId('inspector'), isFalse);
      expect(isConversationSurfaceId(kNewTabSurfaceId), isFalse);
    });

    test('the focused thread maps to its channel surface id', () {
      final id = conversationSurfaceId(
        activeThreadId: 'thread-1',
        channels: const [
          ChannelInfo(
            channelId: 'c1',
            name: 'dev',
            threadId: 'thread-1',
            memberIds: [],
            createdAt: '2026-01-01T00:00:00Z',
          ),
        ],
        actors: const [],
        dmThreadOf: (final _) => null,
      );
      expect(id, 'channel:c1');
    });

    test('the focused thread maps to its dm surface id', () {
      final id = conversationSurfaceId(
        activeThreadId: 'thread-9',
        channels: const [],
        actors: const [
          ActorProfile(actorId: 'toby', displayName: 'Toby'),
        ],
        dmThreadOf: (final actorId) => actorId == 'toby' ? 'thread-9' : null,
      );
      expect(id, 'dm:toby');
    });

    test('null or unknown threads map to no surface id', () {
      expect(
        conversationSurfaceId(
          activeThreadId: null,
          channels: const [],
          actors: const [],
          dmThreadOf: (final _) => null,
        ),
        isNull,
      );
      expect(
        conversationSurfaceId(
          activeThreadId: 'group-thread',
          channels: const [],
          actors: const [],
          dmThreadOf: (final _) => null,
        ),
        isNull,
      );
    });

    test('conversation titles: channel name, actor name, honest fallback', () {
      const channels = [
        ChannelInfo(
          channelId: 'c1',
          name: 'dev',
          threadId: 't1',
          memberIds: [],
          createdAt: '2026-01-01T00:00:00Z',
        ),
      ];
      const actors = [ActorProfile(actorId: 'toby', displayName: 'Toby')];
      expect(
        conversationSurfaceTitle(
          'channel:c1',
          channels: channels,
          actors: actors,
        ),
        '#dev',
      );
      expect(
        conversationSurfaceTitle(
          'dm:toby',
          channels: channels,
          actors: actors,
        ),
        'Toby',
      );
      // Unknown rail object: the strip falls back to the raw id.
      expect(
        conversationSurfaceTitle(
          'dm:ghost',
          channels: channels,
          actors: actors,
        ),
        isNull,
      );
      // Registry-covered ids need no override.
      expect(
        conversationSurfaceTitle(
          kConversationsSurfaceId,
          channels: channels,
          actors: actors,
        ),
        isNull,
      );
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
