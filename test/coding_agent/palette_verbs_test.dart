/// Wave J — the palette revision verbs over a hermetic world: the two
/// service verbs ([RealmChatService.proposePalette] /
/// [RealmChatService.applyPalette]) ride the host's OWN participation
/// dispatcher (`DurableRealmTools.invoke`, xsoulspace_agentic_host
/// `durable_realm_tools.dart`), so the laws under test are the
/// harness's, verbatim:
/// * propose is open to EVERY seat and answers the host receipt
///   (`ok`, `beforeSha256`, `afterSha256`, `diff`, `restartRequired`);
/// * a structurally broken candidate answers the `PaletteConfigError`
///   CODE verbatim (`palette_undeclared_provider`, `palette_empty_cast`)
///   — the daemon boot's own parser is the only gate;
/// * apply is OWNER-ONLY: a seat whose profile lacks the
///   `palette_apply` participation grant answers
///   `palette_apply_not_owner` WITH the `recovery` text — and writes
///   nothing. (LA's hermetic seat is a `ProfileActorAuthority` on
///   `RealmActorProfile.standard`, which deliberately carries
///   `palette_propose` but NOT `palette_apply`; the operator issues the
///   apply grant through `agent_local_seat {op: issue,
///   participationOps: [..., "palette_apply"]}` — the named refusal
///   path the host documents in `durable_realm_tools.dart`, G7 gate.)
/// * every lane is a structured envelope: the verbs never throw.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart';
import 'package:lastanswer/data_journal/realm_chat_service.dart';
import 'package:lastanswer/data_journal/realm_world.dart';

/// The fixture palette in the host's wire shape (the key vocabulary of
/// `parsePaletteConfig` — providers/cast, transport, base_url,
/// credential_env, models[{id, max_tokens}]).
Map<String, Object?> _paletteWire() => <String, Object?>{
  'providers': <String, Object?>{
    'modelscope': <String, Object?>{
      'transport': 'openai_compatible',
      'base_url': 'https://api-inference.modelscope.ai/v1',
      'credential_env': 'MODELSCOPE_API_KEY',
      'models': <Object?>[
        <String, Object?>{'id': 'Qwen3.8-Max-Preview', 'max_tokens': 262144},
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
      'model': 'Qwen3.8-Max-Preview',
      'role': 'generative',
      'primary': true,
    },
    <String, Object?>{
      'id': 'openrouter_deepseek',
      'provider': 'openrouter',
      'model': 'deepseek/deepseek-v4.1-flash',
      'role': 'generative',
    },
  ],
};

Map<String, Object?> _deepCopy(final Map<String, Object?> doc) =>
    jsonDecode(jsonEncode(doc))! as Map<String, Object?>;

void main() {
  late Directory temp;
  late RealmChatService service;
  late String configPath;
  late String humanId;

  /// The hermetic seat: a disposable world whose scope dir
  /// (`<temp>/world`) also carries the fixture config, so the host's
  /// write-site walk-up resolves INSIDE the temp tree and the real
  /// device config is never the write target.
  Future<void> openSeat() async {
    final world = await RealmWorld.open(rootOverride: temp.path);
    if (world == null) fail('realm world unsupported on this platform');
    service = RealmChatService(
      debugWorldOverride: world,
      debugRosterOverride: ActorRoster(replicaId: 'tester'),
      debugStartBotDispatcher: false,
    );
    addTearDown(service.dispose);
    // Hermetic health lane: the receipt never reads the device file.
    service.debugPaletteHealthPath = '${temp.path}/palette_health.json';
    await service.ensureReady();
    expect(service.isReady, isTrue, reason: service.error);
    humanId = service.humanActorId!;
  }

  void writeFixtureConfig() {
    Directory('${temp.path}/world/.xsoulspace').createSync(recursive: true);
    File(configPath).writeAsStringSync(
      jsonEncode(<String, Object?>{'model_palette': _paletteWire()}),
    );
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('la_palette_verbs_');
    RealmWorld.debugDeviceHome = temp.path;
    configPath = '${temp.path}/world/.xsoulspace/config.json';
    await openSeat();
    writeFixtureConfig();
  });

  tearDown(() async {
    RealmWorld.debugDeviceHome = null;
    await temp.delete(recursive: true);
  });

  test('propose answers the host receipt for a valid candidate — '
      'read-only, never a write', () async {
    final candidate = _deepCopy(_paletteWire());
    (candidate['cast']! as List<Object?>).add(<String, Object?>{
      'id': 'modelscope_qwen38flash',
      'provider': 'modelscope',
      'model': 'Qwen3.8-Max-Preview',
      'role': 'generative',
    });
    final before = File(configPath).readAsStringSync();

    final receipt = await service.proposePalette(candidate);

    expect(receipt['ok'], isTrue);
    expect(receipt['kind'], 'palette_proposal');
    expect(receipt['configPath'], configPath);
    // The race-guard fingerprint the apply lane consumes.
    expect(receipt['beforeSha256'], isA<String>());
    expect(
      (receipt['beforeSha256']! as String).isNotEmpty,
      isTrue,
    );
    expect(receipt['afterSha256'], isA<String>());
    expect(receipt['afterSha256'], isNot(receipt['beforeSha256']));
    final diff = receipt['diff']! as Map;
    expect(diff['added'], contains('modelscope_qwen38flash'));
    // The verb NAMES the restart route; it never restarts anything.
    expect(receipt['restartRequired'], isTrue);
    // Propose is read-only: the winning config did not move.
    expect(File(configPath).readAsStringSync(), before);
  });

  test('a structurally broken candidate answers the PaletteConfigError '
      'code VERBATIM', () async {
    // The brief's break: the `providers` key is missing while a cast
    // row still names one — the daemon boot's own parser refuses.
    final broken = <String, Object?>{
      'cast': <Object?>[
        <String, Object?>{
          'id': 'ghost',
          'provider': 'absent',
          'model': 'x',
        },
      ],
    };

    final receipt = await service.proposePalette(broken);

    expect(receipt['ok'], isFalse);
    expect(receipt['bounce'], 'palette_undeclared_provider');
    expect(receipt['refusal'], isA<String>());
    expect(receipt['refusal']! as String, contains('not '));
    expect(receipt['refusal']! as String, contains('declared'));

    // A missing `cast` is the parser's other structural refusal.
    final noCast = await service.proposePalette(<String, Object?>{
      'providers': <String, Object?>{},
    });
    expect(noCast['ok'], isFalse);
    expect(noCast['bounce'], 'palette_empty_cast');
  });

  test('apply without the owner grant answers palette_apply_not_owner '
      'WITH the recovery text — and writes nothing', () async {
    final candidate = _deepCopy(_paletteWire());
    (candidate['cast']! as List<Object?>).add(<String, Object?>{
      'id': 'modelscope_qwen38flash',
      'provider': 'modelscope',
      'model': 'Qwen3.8-Max-Preview',
      'role': 'generative',
    });
    final before = File(configPath).readAsStringSync();

    final outcome = await service.applyPalette(candidate);

    expect(outcome['ok'], isFalse);
    expect(outcome['bounce'], 'palette_apply_not_owner');
    // The refusal detail carries actor + grantId + the recovery route,
    // verbatim from the host's owner gate — never a bare error.
    final refusal = outcome['refusal'];
    expect(refusal, isA<Map>());
    final detail = refusal! as Map;
    expect(detail['actor'], humanId);
    expect(detail['recovery'], isA<String>());
    final recovery = detail['recovery']! as String;
    expect(recovery, contains('owner-only'));
    expect(recovery, contains('palette_apply'));
    expect(recovery, contains('agent_local_seat'));
    expect(recovery, contains('palette_propose stays open'));
    // Nothing landed: no config write, no revision journal row.
    expect(File(configPath).readAsStringSync(), before);
    expect(
      File('$configPath.bak').existsSync(),
      isFalse,
    );
  });

  test('the race guard rides the apply signature (expectedBeforeSha256 '
      'is the proposal receipt’s fingerprint)', () async {
    // The owner gate answers FIRST for this seat — the guard is part of
    // the verb's shape, asserted here so the seam stays honest about
    // what it forwards.
    final outcome = await service.applyPalette(
      _deepCopy(_paletteWire()),
      expectedBeforeSha256: 'stale-fingerprint',
    );
    expect(outcome['ok'], isFalse);
    expect(outcome['bounce'], 'palette_apply_not_owner');
  });

  test('before the world opens the verbs answer realm_not_ready — '
      'never a throw', () async {
    final cold = RealmChatService(
      debugRosterOverride: ActorRoster(replicaId: 'cold'),
      debugStartBotDispatcher: false,
    );
    addTearDown(cold.dispose);

    final propose = await cold.proposePalette(_paletteWire());
    expect(propose['ok'], isFalse);
    expect(propose['bounce'], 'realm_not_ready');

    final apply = await cold.applyPalette(_paletteWire());
    expect(apply['ok'], isFalse);
    expect(apply['bounce'], 'realm_not_ready');
  });
}
