import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_controller.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_view.dart';

void main() {
  testWidgets('synthetic unknown observation survives journal-only status', (
    tester,
  ) async {
    final controller =
        MeaningExperimentController(
            invoke: (action, _) async {
              if (action == 'rollback') {
                return {
                  'ok': false,
                  'error': 'native_effect_outcome_unknown',
                  'action': action,
                  'proposalId': 'p',
                  'runId': 'r',
                  'native_status': 'rolledBack',
                  'effect_replay_available': false,
                };
              }
              return {
                'ok': true,
                'issued_previews': [
                  {
                    'proposal': {'proposalId': 'p'},
                    'invoked': true,
                  },
                ],
                'native_runs': [
                  {
                    'proposalId': 'p',
                    'runId': 'r',
                    'known_in_session': true,
                    'status': 'rolledBack',
                  },
                ],
              };
            },
          )
          ..proposalId = 'p'
          ..runId = 'r'
          ..rollbackAvailable = true
          ..currentObservation = 'historical candidate';
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MeaningExperimentView(controller: controller)),
      ),
    );
    await tester.tap(find.byKey(const Key('coding_agent.meaning.rollback')));
    await tester.pumpAndSettle();
    // Failed Undo reconciles internally; the main flow needs no Status tap.
    expect(
      find.byKey(const Key('coding_agent.meaning.current_observation_unknown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('coding_agent.meaning.current_observation')),
      findsNothing,
    );
    expect(find.text('historical candidate'), findsNothing);
  });

  testWidgets('real keys show native diff and preserve receipt on remount', (
    tester,
  ) async {
    final calls = <(String, Map<String, Object?>)>[];
    final controller =
        MeaningExperimentController(
            invoke: (action, args) async {
              calls.add((action, args));
              return {
                'ok': true,
                'action': action,
                'runId': 'native-run',
                'elapsed_us': 123,
              };
            },
          )
          ..proposalId = 'issued-proposal'
          ..preview = {
            'proposal': {
              'proposalId': 'issued-proposal',
              'diff': '-before\n+after',
            },
            'baseline_observation': 'Hello, Ada!',
            'candidate_observation': 'Hello, Ada! — updated',
            'evidence': {'stage': 'previewExecuted'},
            'elapsed_us': 456,
          };
    addTearDown(controller.dispose);
    Widget view() => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MeaningExperimentView(controller: controller),
        ),
      ),
    );
    await tester.pumpWidget(view());
    expect(find.text('-before\n+after'), findsNothing);
    expect(find.textContaining('issued-proposal'), findsNothing);
    expect(find.byKey(const Key('coding_agent.meaning.status')), findsNothing);
    expect(
      find.byKey(const Key('coding_agent.meaning.finalize')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('coding_agent.meaning.details')));
    await tester.pumpAndSettle();
    expect(find.text('-before\n+after'), findsOneWidget);
    expect(find.textContaining('Hello, Ada! — updated'), findsOneWidget);
    await tester.tap(find.byKey(const Key('coding_agent.meaning.apply')));
    await tester.pumpAndSettle();
    expect(calls, hasLength(1));
    expect(calls.single.$1, 'apply');
    expect(calls.single.$2, {'proposalId': 'issued-proposal'});
    expect(controller.toJson()['runId'], 'native-run');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(view());
    await tester.tap(find.byKey(const Key('coding_agent.meaning.details')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('coding_agent.meaning.receipt.0')),
      findsOneWidget,
    );
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.byKey(const Key('coding_agent.meaning.rollback')));
    await tester.pumpAndSettle();
    expect(calls.last.$1, 'rollback');
    expect(calls.last.$2, {
      'proposalId': 'issued-proposal',
      'runId': 'native-run',
    });
    expect(controller.rollbackAvailable, false);
  });

  for (final language in ['en', 'it', 'ru']) {
    testWidgets('plain $language Before/After includes all five exact cases', (
      tester,
    ) async {
      const names = ['Ada', '', '2', r'a$b', "x'y"];
      final before = [
        for (final name in names) {'name': name, 'value': 'Hello, $name!'},
      ];
      final after = [
        for (final name in names)
          {'name': name, 'value': 'Hello, $name! — updated'},
      ];
      final controller =
          MeaningExperimentController(
              invoke: (_, _) async => throw StateError('No effect allowed'),
            )
            ..proposalId = 'hidden-native-id'
            ..preview = {
              'proposal': {
                'proposalId': 'hidden-native-id',
                'diff': 'native-diff',
              },
              'baseline_observation': before,
              'candidate_observation': after,
            };
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: const [Locale('en'), Locale('it'), Locale('ru')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: MeaningExperimentView(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final plain = tester
          .widget<SelectableText>(
            find.byKey(const Key('coding_agent.meaning.observations')),
          )
          .data!;
      for (final name in names) {
        expect(plain, contains('Hello, $name!'));
        expect(plain, contains('Hello, $name! — updated'));
      }
      expect(plain, isNot(contains('{name:')));
      expect(find.textContaining('hidden-native-id'), findsNothing);
      expect(find.text('native-diff'), findsNothing);
      await tester.ensureVisible(
        find.byKey(const Key('coding_agent.meaning.details')),
      );
      await tester.tap(find.byKey(const Key('coding_agent.meaning.details')));
      await tester.pumpAndSettle();
      expect(find.text('native-diff'), findsOneWidget);
      expect(find.textContaining('hidden-native-id'), findsOneWidget);
    });
  }

  test(
    'busy refuses a second invocation; absent preview has no effect',
    () async {
      final waiting = Completer<Map<String, Object?>>();
      var calls = 0;
      final controller = MeaningExperimentController(
        invoke: (_, _) {
          calls++;
          return waiting.future;
        },
      );
      addTearDown(controller.dispose);
      expect(
        (await controller.action('apply'))['error'],
        'meaning_preview_required',
      );
      expect(calls, 0);
      final pending = controller.action('status');
      expect(
        (await controller.action('status'))['error'],
        'meaning_operation_busy',
      );
      expect(calls, 1);
      waiting.complete({
        'ok': false,
        'error': 'meaning_extension_context_lost',
      });
      await pending;
      expect(controller.refusal, 'meaning_extension_context_lost');
      expect(controller.busy, false);
    },
  );
}
