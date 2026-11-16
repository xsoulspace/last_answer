import 'package:core/src/generated/intl/S.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';

void main() {
  // ADR 0143 — the Brain override card: Automatic vs the actor's own
  // ordered set, and the self-rebind switch. The save contract is the
  // world's ensure/bind vocabulary (brainSet + selfBind), so the pins
  // read the MAP, never pixels (the candidate test seam law).
  Future<void> pump(
    WidgetTester tester, {
    required void Function({
      required String displayName,
      required String role,
      required String systemPrompt,
      required String brainRef,
      required String? avatar,
      required List<String> brainSet,
      required bool selfBind,
    })
    onSave,
    List<String> initialBrainSet = const <String>[],
    bool initialSelfBind = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ActorProfileEditor(
              profile: const ActorProfile(
                actorId: 'scout',
                displayName: 'Scout',
                brainRef: 'cast:alpha',
              ),
              brainOptions: const [
                (ref: 'cast:alpha', label: 'Alpha'),
                (ref: 'cast:beta', label: 'Beta'),
                (ref: 'cast:gamma', label: 'Gamma'),
              ],
              initialBrainSet: initialBrainSet,
              initialSelfBind: initialSelfBind,
              key: const ValueKey('actor.editor'),
              onSave: onSave,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Automatic is the seed for an empty set: the save hands '
      'an EMPTY list (the world policy whole)', (final tester) async {
    List<String>? savedSet;
    await pump(
      tester,
      onSave: ({
        required displayName,
        required role,
        required systemPrompt,
        required brainRef,
        required avatar,
        required brainSet,
        required selfBind,
      }) {
        savedSet = brainSet;
      },
    );
    expect(
      find.byKey(const ValueKey('actor.edit.brainSet.add')),
      findsNothing,
      reason: 'Automatic hides the set editor entirely',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('actor.edit.save')),
    );
    await tester.tap(find.byKey(const ValueKey('actor.edit.save')));
    await tester.pump();
    expect(savedSet, isEmpty);
  });

  testWidgets('own set: seeded rows, add appends, remove drops, and the '
      'save hands the ORDER', (final tester) async {
    List<String>? savedSet;
    await pump(
      tester,
      initialBrainSet: const ['beta', 'alpha'],
      onSave: ({
        required displayName,
        required role,
        required systemPrompt,
        required brainRef,
        required avatar,
        required brainSet,
        required selfBind,
      }) {
        savedSet = brainSet;
      },
    );
    // The spoken labels render, in order.
    expect(find.text('1. Beta'), findsOneWidget);
    expect(find.text('2. Alpha'), findsOneWidget);
    // Add appends at the tail.
    await tester.tap(find.byKey(const ValueKey('actor.edit.brainSet.add')));
    await tester.pump();
    await tester.tap(find.text('Gamma').last);
    await tester.pump();
    // Reorder: move the last row up.
    await tester.tap(
      find.byKey(const ValueKey('actor.edit.brainSet.up.gamma')),
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('actor.edit.save')));
    await tester.tap(find.byKey(const ValueKey('actor.edit.save')));
    await tester.pump();
    expect(savedSet, ['beta', 'gamma', 'alpha']);
  });

  testWidgets('switching Own set OFF clears the set on save', (
      final tester,
    ) async {
    List<String>? savedSet;
    await pump(
      tester,
      initialBrainSet: const ['beta'],
      onSave: ({
        required displayName,
        required role,
        required systemPrompt,
        required brainRef,
        required avatar,
        required brainSet,
        required selfBind,
      }) {
        savedSet = brainSet;
      },
    );
    await tester.tap(find.byKey(const ValueKey('actor.edit.brainSet.own')));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('actor.edit.save')),
    );
    await tester.tap(find.byKey(const ValueKey('actor.edit.save')));
    await tester.pump();
    expect(savedSet, isEmpty);
  });

  testWidgets('the self-rebind switch rides the save (the row selfBind)',
      (final tester) async {
    bool? savedSelfBind;
    await pump(
      tester,
      onSave: ({
        required displayName,
        required role,
        required systemPrompt,
        required brainRef,
        required avatar,
        required brainSet,
        required selfBind,
      }) {
        savedSelfBind = selfBind;
      },
    );
    await tester.tap(find.byKey(const ValueKey('actor.edit.selfBind')));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('actor.edit.save')),
    );
    await tester.tap(find.byKey(const ValueKey('actor.edit.save')));
    await tester.pump();
    expect(savedSelfBind, isFalse);
  });
}
