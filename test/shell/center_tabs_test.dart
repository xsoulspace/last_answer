// The surface-id vocabulary of the ONE registry (WAVE 5): which ids
// share the conversation slot, which map from the service's focused
// thread, their human titles — and which tabs carry the pin
// affordance.
import 'package:flutter_test/flutter_test.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';

import 'package:lastanswer/shell/surfaces.dart';

void main() {
  group('conversation mapping', () {
    test('isConversationSurfaceId covers the slot vocabularies', () {
      expect(isConversationSurfaceId(kConversationsSurfaceId), isTrue);
      expect(isConversationSurfaceId('dm:actor-x'), isTrue);
      expect(isConversationSurfaceId('channel:c1'), isTrue);
      expect(isConversationSurfaceId('browser'), isFalse);
      expect(isConversationSurfaceId('inspector'), isFalse);
      expect(isConversationSurfaceId(kNewTabSurfaceId), isFalse);
      expect(isConversationSurfaceId(kPeopleSurfaceId), isFalse);
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
      // Unknown rail object: the bar falls back to the raw id.
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

  }
