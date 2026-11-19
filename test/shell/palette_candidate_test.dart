/// Models refactor (2026-11-14) — the candidate STATE MACHINE, unit-
/// tested widget-free (the extraction's whole point): every verb, every
/// structured refusal with the refs it names, the rename-follows-cast
/// law, the persisted primary, the ladder reorder, the JSON lane's
/// named parse refusals, the rebase law (clean adopts / dirty keeps),
/// and the propose → receipt → apply lane over a fake verb lane.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/ui_models/palette_candidate.dart';

/// The fixture wire document: two providers, three cast rows (one
/// primary, one builtin), the host parser's own key vocabulary.
Map<String, Object?> _doc() => <String, Object?>{
  'providers': <String, Object?>{
    'modelscope': <String, Object?>{
      'transport': 'openai_compatible',
      'base_url': 'https://api-inference.modelscope.ai/v1',
      'credential_env': 'MODELSCOPE_API_KEY',
      'models': <Object?>[
        <String, Object?>{'id': 'Qwen3.8-Max', 'max_tokens': 262144},
      ],
    },
    'openrouter': <String, Object?>{
      'transport': 'openrouter',
      'credential_env': 'OPENROUTER_API_KEY',
      'models': <Object?>[
        <String, Object?>{'id': 'deepseek/deepseek-v4.1-flash'},
      ],
    },
  },
  'cast': <Object?>[
    <String, Object?>{
      'id': 'modelscope_qwen38max',
      'provider': 'modelscope',
      'model': 'Qwen3.8-Max',
      'role': 'generative',
      'primary': true,
    },
    <String, Object?>{
      'id': 'openrouter_deepseek',
      'provider': 'openrouter',
      'model': 'deepseek/deepseek-v4.1-flash',
      'role': 'generative',
    },
    <String, Object?>{'id': 'qwen', 'builtin': true, 'role': 'generative'},
  ],
};

/// The verb lane's test double: canned envelopes, recorded calls.
final class _FakeLane implements PaletteVerbLane {
  Map<String, Object?> receipt = <String, Object?>{
    'ok': true,
    'beforeSha256': 'before',
  };
  Map<String, Object?> outcome = <String, Object?>{
    'ok': true,
    'revisionId': 'rev-1',
    'restartRequired': true,
  };
  final List<Map<String, Object?>> proposed = <Map<String, Object?>>[];
  final List<Map<String, Object?>> applied = <Map<String, Object?>>[];
  String? expectedBefore;

  @override
  Future<Map<String, Object?>> propose(
    final Map<String, Object?> candidate,
  ) async {
    proposed.add(candidate);
    return receipt;
  }

  @override
  Future<Map<String, Object?>> apply(
    final Map<String, Object?> candidate, {
    final String? expectedBeforeSha256,
  }) async {
    applied.add(candidate);
    expectedBefore = expectedBeforeSha256;
    return outcome;
  }
}

void main() {
  group('the provider verbs', () {
    test('addProvider lands the wire keys; duplicates and empty ids '
        'refuse with their code', () {
      final model = PaletteCandidateModel(live: _doc());
      expect(
        model.addProvider(
          id: 'groq',
          transport: 'openai_compatible',
          baseUrl: 'https://api.groq.com/openai/v1',
          credentialEnv: 'GROQ_API_KEY',
        ),
        isTrue,
      );
      final groq = model.providers['groq']! as Map<String, Object?>;
      expect(groq['transport'], 'openai_compatible');
      expect(groq['base_url'], 'https://api.groq.com/openai/v1');
      expect(groq['credential_env'], 'GROQ_API_KEY');
      expect(groq['models'], <Object?>[]);
      expect(model.dirty, isTrue);

      expect(
        model.addProvider(id: 'groq', transport: 'openrouter'),
        isFalse,
      );
      expect(model.refusal?.code, 'duplicateProvider');
      expect(model.refusal?.refs, <String>['groq']);
      expect(model.addProvider(id: '', transport: 'openrouter'), isFalse);
      expect(model.refusal?.code, 'emptyId');
    });

    test('a referenced provider id is IMMUTABLE and removal refuses '
        'NAMING the cast rows', () {
      final model = PaletteCandidateModel(live: _doc());
      expect(
        model.editProvider(
          oldId: 'modelscope',
          id: 'renamed',
          transport: 'openai_compatible',
        ),
        isFalse,
      );
      expect(model.refusal?.code, 'idImmutable');
      expect(model.refusal?.refs, <String>['modelscope_qwen38max']);
      expect(
        model.removeProvider('modelscope'),
        isFalse,
        reason: 'the cast row still rides it',
      );
      expect(model.refusal?.code, 'providerInUse');

      // An unreferenced provider edits and removes freely.
      expect(
        model.editProvider(
          oldId: 'openrouter',
          id: 'openrouter',
          transport: 'openai_compatible',
          baseUrl: 'https://openrouter.ai/api/v1',
        ),
        isTrue,
      );
      expect(model.addProvider(id: 'solo', transport: 'openrouter'), isTrue);
      expect(model.removeProvider('solo'), isTrue);
      expect(model.providers.containsKey('solo'), isFalse);
    });

    test('editProvider drops emptied optionals (the wire omission law)', () {
      final model = PaletteCandidateModel(live: _doc());
      expect(
        model.editProvider(
          oldId: 'openrouter',
          id: 'openrouter',
          transport: 'openrouter',
          baseUrl: '   ',
          credentialEnv: '',
        ),
        isTrue,
      );
      final provider = model.providers['openrouter']! as Map<String, Object?>;
      expect(provider.containsKey('base_url'), isFalse);
      expect(provider.containsKey('credential_env'), isFalse);
    });
  });

  group('the model verbs', () {
    test('the upsert verb adds with the FULL field set and edits every '
        'schema key; nulls drop the key', () {
      final model = PaletteCandidateModel(live: _doc());
      expect(
        model.editModel(
          providerId: 'modelscope',
          id: 'Qwen3.7-Plus',
          maxTokens: 131072,
          reasoningEffort: 'high',
          includeReasoning: true,
          capabilities: <String, bool>{'tools': true},
        ),
        isTrue,
      );
      var models = model.modelsOf('modelscope');
      expect(models.length, 2);
      expect(models.last['max_tokens'], 131072);
      expect(models.last['reasoning_effort'], 'high');
      expect(models.last['include_reasoning'], true);
      expect(models.last['capabilities'], <String, Object?>{'tools': true});

      // Edit: a null field DROPS the key, a rename carries the casts.
      expect(
        model.editModel(
          providerId: 'modelscope',
          oldId: 'Qwen3.8-Max',
          id: 'Qwen3.8-Max-Preview',
          maxOutputTokens: 8192,
        ),
        isTrue,
      );
      models = model.modelsOf('modelscope');
      expect(models.first['id'], 'Qwen3.8-Max-Preview');
      expect(models.first.containsKey('max_tokens'), isFalse);
      expect(models.first['max_output_tokens'], 8192);
      // The cast row followed the rename.
      final cast = model.cast.whereType<Map<Object?, Object?>>().first;
      expect(cast['model'], 'Qwen3.8-Max-Preview');
    });

    test('removeModel refuses while a cast row references it, naming '
        'the row', () {
      final model = PaletteCandidateModel(live: _doc());
      expect(
        model.removeModel(providerId: 'modelscope', modelId: 'Qwen3.8-Max'),
        isFalse,
      );
      expect(model.refusal?.code, 'modelInUse');
      expect(model.refusal?.refs, <String>['modelscope_qwen38max']);
      expect(
        model.removeModel(
          providerId: 'openrouter',
          modelId: 'deepseek/deepseek-v4.1-flash',
        ),
        isFalse,
      );
      // An unreferenced model removes freely.
      expect(
        model.editModel(providerId: 'openrouter', id: 'unused'),
        isTrue,
      );
      expect(
        model.removeModel(providerId: 'openrouter', modelId: 'unused'),
        isTrue,
      );
    });

    test('a duplicate model id refuses; a bad number is the UI-owned '
        'refusal', () {
      final model = PaletteCandidateModel(live: _doc());
      expect(
        model.editModel(providerId: 'modelscope', id: 'Qwen3.8-Max'),
        isFalse,
      );
      expect(model.refusal?.code, 'duplicateModel');
      model.refuseBadNumber();
      expect(model.refusal?.code, 'badNumber');
    });
  });

  group('the bindings verbs', () {
    test('setPrimary moves the ONE mark; moveCast reorders the ladder '
        'and clamps', () {
      final model = PaletteCandidateModel(live: _doc());
      expect(model.setPrimary('openrouter_deepseek'), isTrue);
      final cast = model.cast.whereType<Map<Object?, Object?>>().toList();
      expect(cast[0]['primary'], isNot(true));
      expect(cast[1]['primary'], true);

      expect(model.moveCast('qwen', 0), isTrue);
      final reordered = model.cast.whereType<Map<Object?, Object?>>().toList();
      expect(reordered.first['id'], 'qwen');
      // Clamped: beyond the tail lands at the tail.
      expect(model.moveCast('qwen', 99), isTrue);
      expect(
        model.cast.whereType<Map<Object?, Object?>>().last['id'],
        'qwen',
      );
      expect(model.moveCast('nope', 0), isFalse);
    });
  });

  group('the JSON lane and the rebase law', () {
    test('a broken document is a named refusal; the candidate keeps its '
        'last valid shape', () {
      final model = PaletteCandidateModel(live: _doc())
        ..replaceFromJson('{{{');
      expect(model.refusal?.code, 'jsonInvalid');
      expect(model.providers.containsKey('modelscope'), isTrue);
      model.replaceFromJson('[1,2]');
      expect(model.refusal?.code, 'jsonInvalid');
      model.replaceFromJson('{"providers": {}, "cast": []}');
      expect(model.refusal, isNull);
      expect(model.providers, isEmpty);
      expect(model.dirty, isTrue);
    });

    test('rebase: a clean candidate adopts the new truth, a dirty one '
        'keeps its edits; receipts drop either way', () {
      final model = PaletteCandidateModel(live: _doc());
      final fresh = _doc();
      (fresh['providers']! as Map<String, Object?>)['groq'] = <String, Object?>{
        'transport': 'openrouter',
        'models': <Object?>[],
      };
      model.rebase(fresh);
      expect(model.providers.containsKey('groq'), isTrue);

      model.removeProvider('groq');
      expect(model.dirty, isTrue);
      model.rebase(_doc());
      expect(
        model.providers.containsKey('groq'),
        isFalse,
        reason: 'the dirty candidate keeps its edit',
      );
      expect(model.receipt, isNull);
    });

    test('revert restores the live bytes and clears every note', () {
      final model = PaletteCandidateModel(live: _doc())
        ..addProvider(id: 'groq', transport: 'openrouter')
        ..revert();
      expect(model.dirty, isFalse);
      expect(model.providers.containsKey('groq'), isFalse);
      expect(model.refusal, isNull);
    });
  });

  group('the propose → receipt → apply lane', () {
    test('propose validates through the lane; apply carries the '
        "receipt's before-sha and re-bases live on ok", () async {
      final lane = _FakeLane();
      final model = PaletteCandidateModel(live: _doc(), lane: lane)
        ..addProvider(id: 'groq', transport: 'openrouter');

      await model.propose();
      expect(lane.proposed.length, 1);
      expect(model.receiptOk, isTrue);

      await model.apply();
      expect(lane.applied.length, 1);
      expect(lane.expectedBefore, 'before');
      expect(model.dirty, isFalse, reason: 'the candidate is now live');
      expect(model.receipt, isNull, reason: 'the apply consumed it');
      expect(model.applyOutcome?['revisionId'], 'rev-1');
      expect(model.live['providers'], model.candidate['providers']);
    });

    test('a non-owner apply keeps the candidate dirty and surfaces the '
        'outcome envelope verbatim', () async {
      final lane = _FakeLane()
        ..outcome = <String, Object?>{
          'ok': false,
          'bounce': 'palette_apply_not_owner',
          'refusal': <String, Object?>{
            'recovery': 'owner-only — re-issue via agent_local_seat',
          },
        };
      final model = PaletteCandidateModel(live: _doc(), lane: lane)
        ..addProvider(id: 'groq', transport: 'openrouter');
      await model.propose();
      await model.apply();
      expect(model.dirty, isTrue);
      expect(model.applyOutcome?['bounce'], 'palette_apply_not_owner');
    });

    test('a mutation drops the stale receipt; a seat-less lane refuses '
        'with noSeat', () async {
      final lane = _FakeLane();
      final model = PaletteCandidateModel(live: _doc(), lane: lane)
        ..addProvider(id: 'groq', transport: 'openrouter');
      await model.propose();
      expect(model.receiptOk, isTrue);
      model.editModel(providerId: 'groq', id: 'extra-model');
      expect(model.receipt, isNull, reason: 'stale by law');

      final seatless = PaletteCandidateModel(live: _doc());
      await seatless.propose();
      expect(seatless.refusal?.code, 'noSeat');
    });

    test('the debug seam republishes on every mutation', () {
      PaletteCandidateModel.debugLastCandidate = null;
      final model = PaletteCandidateModel(live: _doc());
      expect(
        PaletteCandidateModel.debugLastCandidate?['providers'],
        isNotNull,
      );
      model.addProvider(id: 'groq', transport: 'openrouter');
      expect(
        (PaletteCandidateModel.debugLastCandidate!['providers']! as Map)
            .containsKey('groq'),
        isTrue,
      );
    });
  });
}
