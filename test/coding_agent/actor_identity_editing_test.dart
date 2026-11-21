import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/data_journal/actor_creation.dart';
import 'package:lastanswer/data_journal/realm_bot_host.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/realm_world.dart';
import 'package:lastanswer/ui_chat/actor_profile_editor.dart';
import 'package:lastanswer/ui_chat/world_chat_surface.dart';
import 'package:lastanswer/ui_shell/shell_layout.dart';
import 'package:lastanswer/ui_shell/shell_scope.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/ui_shell/surfaces.dart';
import 'package:lastanswer/ui_shell/view_people.dart';
import 'package:material_ui/material_ui.dart';

Future<RealmWorld> _hermeticWorld() async {
  final temp = await Directory.systemTemp.createTemp('la_actor_edit_');
  addTearDown(() => temp.delete(recursive: true));
  final world = await RealmWorld.open(rootOverride: temp.path);
  if (world == null) fail('realm world unsupported on this platform');
  return world;
}

void main() {
  // ADR 0023 §1a — identities are EDITABLE: the persona prompt, the
  // brain binding incl. sampling. One mechanism (updateActorIdentity /
  // RealmChatService.updateActor), two surfaces (the context column's
  // actor panel, the Settings actors pane). The world record is the
  // durable identity — an edit must survive a restart — and the bot
  // host must rebuild a worker whose profile materially changed.
  group('roster persistence', () {
    test('ActorProfile JSON round-trip carries the persona', () {
      const profile = ActorProfile(
        actorId: 'toby',
        displayName: 'Toby Researcher',
        brainRef: 'local:qwen?temperature=0.9&repetitionPenalty=1.2',
        role: 'researcher',
        systemPrompt: 'You are Toby, a careful researcher.',
      );
      final restored = ActorProfile.fromJson(
        Map<String, dynamic>.from(profile.toJson()),
      );
      expect(restored, profile);
      expect(restored.systemPrompt, 'You are Toby, a careful researcher.');

      // An old replica payload without the field reads as absent.
      final legacy = ActorProfile.fromJson(const <String, dynamic>{
        'actorId': 'old',
        'displayName': 'Old',
      });
      expect(legacy.systemPrompt, '');
    });

    test('roster upsert/get round-trips the persona verbatim', () {
      final roster = ActorRoster(replicaId: 'tester');
      const persona = 'Line one.\n\n  Line two — leading space kept. ';
      roster.upsert(
        const ActorProfile(
          actorId: 'toby',
          displayName: 'Toby',
          systemPrompt: persona,
        ),
      );
      expect(roster.get('toby')?.systemPrompt, persona);
    });
  });

  group('brainRef helpers', () {
    test('brainRefBase strips the sampling query', () {
      expect(brainRefBase('local:qwen'), 'local:qwen');
      expect(brainRefBase('local:qwen?temperature=0.9'), 'local:qwen');
      expect(brainRefBase('openrouter:acme/model'), 'openrouter:acme/model');
      expect(brainRefBase(''), '');
    });

    test('buildLocalBrainRef rebuilds the parsed grammar', () {
      expect(buildLocalBrainRef('qwen'), 'local:qwen');
      expect(
        buildLocalBrainRef('qwen', temperature: 0.5),
        'local:qwen?temperature=0.5',
      );
      expect(
        buildLocalBrainRef('qwen', repetitionPenalty: 1.15),
        'local:qwen?repetitionPenalty=1.15',
      );
      expect(
        buildLocalBrainRef(
          'qwen3-1.7b',
          temperature: 0.7,
          repetitionPenalty: 1.1,
        ),
        'local:qwen3-1.7b?temperature=0.7&repetitionPenalty=1.1',
      );
    });

    test('actorDisplayFallback names legacy human ids, else the bare id', () {
      expect(actorDisplayFallback('human-1793337269742932'), 'Human');
      expect(actorDisplayFallback('bot-9f'), 'bot-9f');
      expect(actorDisplayFallback('humanish'), 'humanish');
      expect(actorDisplayFallback('human-1x'), 'human-1x');
    });
  });

  group('bot rebuild rule', () {
    test('botProfileMateriallyChanged covers persona, brain and identity', () {
      const live = ActorProfile(
        actorId: 'b',
        displayName: 'B',
        brainRef: 'local:qwen',
        systemPrompt: 'v1',
      );
      // Unchanged: no rebuild.
      expect(botProfileMateriallyChanged(live: live, stored: live), isFalse);
      // Sampling-only brain edits DO rebuild (the binding carries the
      // sampling query — an edited temperature must reach the engine).
      expect(
        botProfileMateriallyChanged(
          live: live,
          stored: const ActorProfile(
            actorId: 'b',
            displayName: 'B',
            brainRef: 'local:qwen?temperature=0.5',
            systemPrompt: 'v1',
          ),
        ),
        isTrue,
      );
      for (final edited in const [
        ActorProfile(actorId: 'b', displayName: 'B2', systemPrompt: 'v1'),
        ActorProfile(actorId: 'b', displayName: 'B', role: 'reviewer'),
        ActorProfile(actorId: 'b', displayName: 'B', systemPrompt: 'v2'),
        ActorProfile(actorId: 'b', displayName: 'B', brainRef: 'local:lfm'),
      ]) {
        expect(
          botProfileMateriallyChanged(live: live, stored: edited),
          isTrue,
          reason: 'editing $edited must rebuild the worker',
        );
      }
    });

    test('syncBots rebuilds a materially changed worker, keeps an unchanged '
        'one, and never resurrects the removed', () async {
      final world = await _hermeticWorld();
      final host = RealmBotHost(
        world: world,
        humanActorId: 'human-tester',
        resolveOpenRouterApiKey: () => null,
        debugStartDispatcher: false,
      );
      addTearDown(host.stopAll);
      const actor = ActorProfile(
        actorId: 'bot-rebuild',
        displayName: 'Rebuilder',
        brainRef: 'openrouter:acme/test-model',
        systemPrompt: 'v1',
      );
      host.syncBots(const [actor]);
      final first = host.debugLoopFor('bot-rebuild');
      expect(first, isNotNull);
      expect(host.isRunning('bot-rebuild'), isTrue);

      // Unchanged profile: the worker survives.
      host.syncBots(const [actor]);
      expect(identical(host.debugLoopFor('bot-rebuild'), first), isTrue);

      // Edited persona: the worker is REPLACED (stop + start) —
      // today's failure was an edited bot silently keeping the old
      // persona/engine.
      host.syncBots(const [
        ActorProfile(
          actorId: 'bot-rebuild',
          displayName: 'Rebuilder',
          brainRef: 'openrouter:acme/test-model',
          systemPrompt: 'v2',
        ),
      ]);
      final second = host.debugLoopFor('bot-rebuild');
      expect(second, isNotNull);
      expect(identical(second, first), isFalse);

      // Removed from the roster: the worker stops.
      host.syncBots(const <ActorProfile>[]);
      expect(host.isRunning('bot-rebuild'), isFalse);
    });
  });

  group('updateActorIdentity over a hermetic world', () {
    test('create persists the persona; partial edits preserve; unknown '
        'refuses by name', () async {
      final world = await _hermeticWorld();
      final roster = ActorRoster(replicaId: 'tester');
      final toby = await createActorIdentity(
        roster: roster,
        world: world,
        displayName: 'Toby Researcher',
        kind: ActorKind.model,
        brainRef: 'local:qwen',
        role: 'researcher',
        systemPrompt: 'You are Toby, a careful researcher.',
      );

      // The durable world record carries the persona (adopt-at-start
      // re-materializes identities from exactly this record).
      final record = await world.store.read('realm_actors', toby.actorId);
      expect(record, isNotNull);
      expect(record!['systemPrompt'], 'You are Toby, a careful researcher.');
      expect(record['displayName'], 'Toby Researcher');
      expect(record['brainRef'], 'local:qwen');

      // A plain re-register (a bot session's register) must NOT wipe it.
      await world.sessionFor(toby.actorId).register();
      final preserved = await world.store.read('realm_actors', toby.actorId);
      expect(preserved!['systemPrompt'], 'You are Toby, a careful researcher.');

      // Partial edit: name only — persona/brain/role untouched.
      final edited = await updateActorIdentity(
        roster: roster,
        world: world,
        actorId: toby.actorId,
        displayName: 'Toby Prime',
      );
      expect(edited.displayName, 'Toby Prime');
      expect(edited.systemPrompt, 'You are Toby, a careful researcher.');
      expect(edited.brainRef, 'local:qwen');
      expect(edited.role, 'researcher');
      final afterEdit = await world.store.read('realm_actors', toby.actorId);
      expect(afterEdit!['displayName'], 'Toby Prime');
      expect(afterEdit['systemPrompt'], 'You are Toby, a careful researcher.');

      // The persona may be cleared — and the clear is durable.
      await updateActorIdentity(
        roster: roster,
        world: world,
        actorId: toby.actorId,
        systemPrompt: '',
      );
      expect(roster.get(toby.actorId)?.systemPrompt, '');
      final cleared = await world.store.read('realm_actors', toby.actorId);
      expect(cleared!['systemPrompt'], '');

      // Sampling edit lands in the binding exactly as the grammar reads
      // it back.
      final sampled = await updateActorIdentity(
        roster: roster,
        world: world,
        actorId: toby.actorId,
        brainRef: buildLocalBrainRef('qwen', temperature: 0.5),
      );
      expect(sampled.brainRef, 'local:qwen?temperature=0.5');

      // Unknown actor: a NAMED refusal, never an implicit mint.
      expect(
        () => updateActorIdentity(
          roster: roster,
          world: world,
          actorId: 'ghost',
          displayName: 'Ghost',
        ),
        throwsA(
          isA<UnknownActorException>().having(
            (error) => error.toString(),
            'toString',
            'unknown_actor:ghost',
          ),
        ),
      );
    });
  });

  group('RealmChatService.updateActor', () {
    test('refuses an unknown actor with a named error', () async {
      final world = await _hermeticWorld();
      final roster = ActorRoster(replicaId: 'tester');
      final service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();
      final ok = await service.updateActor(
        actorId: 'ghost',
        displayName: 'Ghost',
      );
      expect(ok, isFalse);
      expect(service.error, contains('unknown_actor'));
    });
  });

  testWidgets(
    'the people view: header identity click focuses the actor profile, '
    'the inline edit saves through updateActor (roster + world), back '
    'returns to the conversation',
    (final tester) async {
      // ALL setup rides REAL IO (the kernel store) — inside runAsync,
      // or the FakeAsync zone parks the first store await forever.
      late final RealmChatService service;
      late final RealmWorld world;
      late final ActorRoster roster;
      late final ActorProfile toby;
      await tester.runAsync(() async {
        final temp = await Directory.systemTemp.createTemp('la_actor_edit_');
        addTearDown(() => temp.delete(recursive: true));
        world = (await RealmWorld.open(rootOverride: temp.path))!;
        roster = ActorRoster(replicaId: 'tester');
        service = RealmChatService(
          debugWorldOverride: world,
          debugRosterOverride: roster,
          debugStartBotDispatcher: false,
        );
        addTearDown(service.dispose);
        await service.ensureReady();
        toby = (await service.createActor(
          displayName: 'Toby Researcher',
          kind: ActorKind.model,
          brainRef: '',
          role: 'researcher',
          systemPrompt: 'You are Toby, a careful researcher.',
        ))!;
        await service.startThread(
          topic: 'Toby Researcher',
          participants: <String>[toby.actorId],
        );
      });

      // The same bridge the shell installs: a header-identity tap
      // hosts the people view on the actor (phase 1 scope seam).
      final peopleFocus = PeopleFocus();
      addTearDown(peopleFocus.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<RealmChatService>.value(
          value: service,
          child: MaterialApp(
            // The kit overlay host: LaTooltip/LaMenuAnchor build
            // PortalTargets even while closed (the house pattern).
            builder: (final context, final child) =>
                Portal(child: child ?? const SizedBox.shrink()),
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(
              body: ViewScope(
                layout: ShellLayout.defaultLayout(),
                surfaces: const <String, SurfaceSpec>{},
                onChanged: (final _) {},
                onFocusActor: peopleFocus.focus,
                child: Row(
                  children: [
                    SizedBox(
                      width: ShellTokens.contextColumnWidth,
                      child: PeopleView(service: service, focus: peopleFocus),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: WorldChatSurface(service: service)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Default people list: the conversation's people (the DM hides
      // the topic), rows keyed per actor.
      expect(peopleFocus.actorId, isNull);
      expect(
        find.byKey(ValueKey('shell.context.person.${toby.actorId}')),
        findsOneWidget,
      );

      // The conversation header's identity IS the entry point: tapping
      // it focuses the actor.
      await tester.tap(find.byKey(const ValueKey('worldchat.identity')));
      await tester.pump();
      expect(peopleFocus.actorId, toby.actorId);
      expect(find.byKey(const ValueKey('shell.context.actor')), findsOneWidget);
      expect(find.text('Toby Researcher'), findsWidgets);
      // The panel's identity line AND the header's meta both render it.
      expect(find.text('MODEL · researcher'), findsWidgets);
      expect(find.text('You are Toby, a careful researcher.'), findsOneWidget);

      // The people rows focus too.
      await tester.tap(find.byKey(const ValueKey('shell.context.actor.back')));
      await tester.pump();
      expect(peopleFocus.actorId, isNull);
      await tester.tap(
        find.byKey(ValueKey('shell.context.person.${toby.actorId}')),
      );
      await tester.pump();
      expect(peopleFocus.actorId, toby.actorId);

      // Edit mode: the same editor the Settings pane embeds.
      await tester.tap(find.byKey(const ValueKey('shell.context.actor.edit')));
      await tester.pump();
      final nameField = tester.widget<LaField>(
        find.byKey(const ValueKey(actorEditorNameKey)),
      );
      expect(nameField.controller?.text, 'Toby Researcher');
      await tester.enterText(
        find.byKey(const ValueKey(actorEditorNameKey)),
        'Toby Prime',
      );
      await tester.enterText(
        find.byKey(const ValueKey(actorEditorPersonaKey)),
        'You are Toby Prime, sharper.',
      );
      // The editor scrolls inside the people view (the N4 brain-set
      // fields grew past a 600px window): reach Save the way a user
      // does.
      await tester.ensureVisible(
        find.byKey(const ValueKey('shell.context.actor.save')),
      );
      await tester.tap(find.byKey(const ValueKey('shell.context.actor.save')));
      // The save rides real IO (kernel store): poll inside runAsync until
      // the roster reflects it (the UI flips back on the same future).
      await tester.runAsync(() async {
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (DateTime.now().isBefore(deadline)) {
          if (roster.get(toby.actorId)?.displayName == 'Toby Prime') break;
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
      });
      await tester.pump();

      // Saved: back to the view mode with the new identity.
      expect(find.text('Toby Prime'), findsWidgets);
      expect(find.text('You are Toby Prime, sharper.'), findsOneWidget);
      expect(roster.get(toby.actorId)?.displayName, 'Toby Prime');
      expect(
        roster.get(toby.actorId)?.systemPrompt,
        'You are Toby Prime, sharper.',
      );
      final record = await tester.runAsync(
        () => world.store.read('realm_actors', toby.actorId),
      );
      expect(record!['displayName'], 'Toby Prime');
      expect(record['systemPrompt'], 'You are Toby Prime, sharper.');
      expect(record['role'], 'researcher');
    },
  );
  // ACTOR EQUALITY (owner law, 2026-11-16): a model-based actor is
  // still an actor — daemon-minted rows (brainCast only, no brainRef)
  // are adopted, editable, DM-able, and their cast brain binds BOTH
  // dispatch planes (LA writes brainCast alongside brainRef).
  group('actor equality (wave N1)', () {
    test('a brainCast-only row is adopted: editable, DM-able, '
        'retireable', () async {
      final world = await _hermeticWorld();
      await world.store.transact(
        (tx) => tx.put('realm_actors', 'minted', <String, Object?>{
          'actorId': 'minted',
          'kind': 'realm_actor',
          'brainCast': 'modelscope_qwen38max',
          'displayName': 'Minted',
          'actorKind': 'model',
        }),
      );
      final roster = ActorRoster(replicaId: 'tester');
      final service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();

      final adopted = roster.get('minted');
      expect(adopted, isNotNull, reason: 'brainCast-only rows are actors');
      expect(adopted!.brainRef, 'cast:modelscope_qwen38max');

      // Editable through the ONE mechanism.
      expect(
        await service.updateActor(
          actorId: 'minted',
          displayName: 'Minted Prime',
        ),
        isTrue,
      );
      expect(roster.get('minted')?.displayName, 'Minted Prime');

      // The cast brain binds both planes: brainCast rides the edit.
      final edited = await world.store.read('realm_actors', 'minted');
      expect(edited!['brainCast'], 'modelscope_qwen38max');

      // DM-able: the reuse-or-create two-member thread.
      await service.openDm('minted');
      expect(service.dmThreadOf('minted'), isNotNull);

      // Retire keeps the durable history; the roster tombstone is the
      // projection half.
      final receipt = await service.retireActor('minted');
      expect(receipt['ok'], true);
      final retired = await world.store.read('realm_actors', 'minted');
      expect(retired!['retiredAt'], isA<String>());
      service.removeActor('minted');
      expect(roster.get('minted'), isNull);
    });

    test('a brainless row is adopted as an EDITABLE identity (the '
        'editor is how it gets a brain); a RETIRED row is named, '
        'never re-adopted', () async {
      final world = await _hermeticWorld();
      await world.store.transact((tx) {
        tx.put('realm_actors', 'brainless', <String, Object?>{
          'actorId': 'brainless',
          'kind': 'realm_actor',
          'displayName': 'Brainless',
        });
        tx.put('realm_actors', 'retired-one', <String, Object?>{
          'actorId': 'retired-one',
          'kind': 'realm_actor',
          'displayName': 'Retired One',
          'brainRef': 'local:qwen',
          'retiredAt': '2026-11-04T18:16:08.327830Z',
          'retireReason': 'hygiene-sweep',
        });
      });
      final roster = ActorRoster(replicaId: 'tester');
      final service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();

      // Editable identity, unbound bot: the brain is assignable.
      final adopted = roster.get('brainless');
      expect(adopted, isNotNull);
      expect(adopted!.brainRef, '');
      expect(
        await service.updateActor(actorId: 'brainless', role: 'seeker'),
        isTrue,
      );

      // Retirement is world truth: named, never live.
      expect(roster.get('retired-one'), isNull);
      final info = service.retiredInfo('retired-one');
      expect(info?['retireReason'], 'hygiene-sweep');
    });

    test('reviveActor strips the retirement marks, re-adopts the '
        'identity and empties the retired projection; refusals name '
        'their input', () async {
      final world = await _hermeticWorld();
      await world.store.transact((tx) {
        tx.put('realm_actors', 'retired-two', <String, Object?>{
          'actorId': 'retired-two',
          'kind': 'realm_actor',
          'displayName': 'Retired Two',
          'brainCast': 'modelscope_qwen38max',
          'retiredAt': '2026-11-04T18:16:08.327830Z',
          'retireReason': 'hygiene-sweep',
        });
        tx.put('realm_actors', 'live-one', <String, Object?>{
          'actorId': 'live-one',
          'kind': 'realm_actor',
          'displayName': 'Live One',
        });
      });
      final roster = ActorRoster(replicaId: 'tester');
      final service = RealmChatService(
        debugWorldOverride: world,
        debugRosterOverride: roster,
        debugStartBotDispatcher: false,
      );
      addTearDown(service.dispose);
      await service.ensureReady();

      // The retired visibility projection: named at boot, never live.
      expect(roster.get('retired-two'), isNull);
      expect(service.retiredRows.containsKey('retired-two'), isTrue);

      // Refusals name their input (the bounce law).
      final unknown = await service.reviveActor('ghost');
      expect(unknown['ok'], isFalse);
      expect('${unknown['bounce']}', contains('actor_unknown'));
      final notRetired = await service.reviveActor('live-one');
      expect(notRetired['ok'], isFalse);
      expect('${notRetired['bounce']}', contains('actor_not_retired'));

      // The revival: marks OFF the durable row, identity re-adopted
      // (the cast synthesis included — actor equality), projection
      // emptied.
      final receipt = await service.reviveActor('retired-two');
      expect(receipt['ok'], isTrue);
      final row = await world.store.read('realm_actors', 'retired-two');
      expect(row?['retiredAt'], isNull);
      expect(row?['retireReason'], isNull);
      expect(service.retiredInfo('retired-two'), isNull);
      expect(service.retiredRows.containsKey('retired-two'), isFalse);
      expect(roster.get('retired-two')?.displayName, 'Retired Two');
      expect(
        roster.get('retired-two')?.brainRef,
        'cast:modelscope_qwen38max',
      );
    });
  });
}
