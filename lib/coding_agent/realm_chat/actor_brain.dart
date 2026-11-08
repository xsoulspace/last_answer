/// ADR 0023 §1a — an actor's brain binding.
///
/// A roster `ActorProfile.brainRef` names the model that speaks FOR the
/// actor. The same binding format serves humans minting actors from
/// Settings and the (later) actor-spawn path, so an identity is the same
/// kind of object whoever mints it.
///
/// Format:
/// - `local:<cast>[?key=value&…]` — a local MLX cast (macOS). `cast` is
///   `qwen` (the default Qwen3 snapshot), `lfm` (LFM2.5), or any cached
///   Qwen3 variant name (`qwen3-1.7b`, `qwen3-0.6b-bf16`, …). Keys are
///   sampling overrides: `temperature` (≥ 0) and `repetitionPenalty`
///   (≥ 1, HF semantics), plus the runtime-adapter binding: `lora` names a
///   PEFT/mlx-lm adapter safetensors file (a REGISTRY id — no `/` —
///   resolves under the loras root, see [resolveLoraAdapterPath]; a value
///   containing `/` is a filesystem path, used as-is) and `loraScale` is
///   the final `alpha / r` multiplier (default 1.0). Unknown keys are
///   ignored; malformed values fall back to the chat defaults — a binding
///   never fails to parse. A `lora` registry id that names nothing makes
///   the whole ref resolve to null (a binding to an adapter this machine
///   does not have names nothing), while a filesystem path is checked at
///   attach time (a missing file is a named generate-time error).
/// - `openrouter:<model-id>` — a hosted OpenRouter model.
/// - `cast:<palette-entry-id>` — a rung of the DISCOVERED ecsai palette
///   (phase G6): the entry's provider transport, endpoint and credential
///   env name come from the config document, never from here. A builtin
///   local name (`cast:qwen`) routes to the local engine; an
///   `openai_compatible` or `openrouter` provider rides the hosted wire
///   with the palette's base_url. An entry the palette does not declare
///   resolves to null — the ref names nothing this world serves.
///
/// Local casts are deliberately first-class: small context windows are
/// the designed-for condition. Their engine lives on ONE persistent
/// background isolate (weights load there once per app run; generates
/// queue through the isolate's port — two bots sharing one engine just
/// queue, now without ever touching the UI isolate).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File, Platform;
import 'dart:isolate';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';
import 'package:xsoulspace_inference_openrouter/xsoulspace_inference_openrouter.dart';

/// Chat brains are not greedy: the echo evidence pinned pure-argmax decode
/// as the degenerate attractor, so a local chat cast decodes at this
/// temperature unless its binding overrides it. A future coding lane may
/// pin 0.0 explicitly.
const defaultChatTemperature = 0.7;

/// Mild HF/CTRL repetition penalty for local chat casts — the second half
/// of the echo evidence. 1.0 (off) is one query parameter away.
const defaultChatRepetitionPenalty = 1.1;

/// One conversation turn as the brain sees it: the actor's own past
/// utterances are assistant turns, everyone else's are user turns.
final class BrainTurn {
  const BrainTurn({required this.fromMe, required this.content});
  final bool fromMe;
  final String content;
}

/// One actor's generation binding: a persona-agnostic conversation call.
abstract interface class ActorBrain {
  /// The brainRef this brain was built from.
  String get ref;

  /// Human-readable label for pickers and status rows.
  String get label;

  /// One completion over the conversation. Throws [BrainUnavailable]
  /// when the engine or credential is missing, [BrainGenerationFailed]
  /// on a failed call.
  Future<String> generate({
    required String system,
    required List<BrainTurn> turns,
  });
}

/// The local part of a `local:` brainRef, parsed.
final class LocalBrainParams {
  const LocalBrainParams({
    required this.cast,
    this.temperature,
    this.repetitionPenalty,
    this.lora,
    this.loraScale,
  });

  /// The cast name (`qwen`, `lfm`, `qwen3-1.7b`, …).
  final String cast;

  /// Explicit sampling override; null = the chat default.
  final double? temperature;
  final double? repetitionPenalty;

  /// The RAW `lora=` binding value: a registry id (no `/` — resolved
  /// against the loras root by [resolveBrain]) or a filesystem path
  /// (containing `/`, used as-is). Null = the bare base weights.
  final String? lora;

  /// The parsed `loraScale=` multiplier; null = the engine default (1.0).
  final double? loraScale;
}

/// Parses the local binding grammar after `local:`: `<cast>[?k=v&…]`.
/// Tolerant by law: unknown keys are ignored, malformed values read as
/// unset (the defaults apply), an empty cast names nothing (null).
LocalBrainParams? parseLocalBrainRef(String brainRef) {
  final ref = brainRef.trim();
  if (!ref.startsWith('local:')) return null;
  var rest = ref.substring('local:'.length);
  var paramsPart = '';
  final query = rest.indexOf('?');
  if (query >= 0) {
    paramsPart = rest.substring(query + 1);
    rest = rest.substring(0, query);
  }
  final cast = rest.trim();
  if (cast.isEmpty) return null;
  double? temperature;
  double? repetitionPenalty;
  String? lora;
  double? loraScale;
  for (final pair in paramsPart.split('&')) {
    final eq = pair.indexOf('=');
    if (eq <= 0) continue; // no key, or bare junk: ignored
    final key = pair.substring(0, eq).trim();
    final value = pair.substring(eq + 1).trim();
    switch (key) {
      case 'temperature':
        temperature = double.tryParse(value);
      case 'repetitionPenalty':
        repetitionPenalty = double.tryParse(value);
      case 'lora' when value.isNotEmpty:
        lora = value;
      case 'loraScale':
        loraScale = double.tryParse(value);
      default:
        break; // unknown keys are ignored, never fatal
    }
  }
  return LocalBrainParams(
    cast: cast,
    temperature: temperature,
    repetitionPenalty: repetitionPenalty,
    lora: lora,
    loraScale: loraScale,
  );
}

/// The loras root a REGISTRY id resolves against when no explicit root is
/// injected: `~/.xsoulspace/loras` (the realm's shared adapter registry).
String defaultLoraRoot() {
  final home = Platform.environment['HOME'];
  return home == null || home.isEmpty
      ? '.xsoulspace/loras'
      : '$home/.xsoulspace/loras';
}

/// The default safetensors file name inside a registry adapter directory.
const _registryAdapterFileName = 'adapter.safetensors';

/// Resolves a `lora=` binding value to a filesystem path, or null when it
/// names nothing.
///
/// Two shapes, decided by the value itself:
/// - A value containing `/` is a FILESYSTEM PATH, used verbatim (relative
///   paths ride the process cwd; ABSOLUTE paths are allowed and logged —
///   a brainRef carrying one is visible in chats, so the log is the audit
///   trail). No `~` expansion and no URL decoding: a binding is plain text.
/// - Otherwise it is a REGISTRY id, resolved ONLY inside the loras root
///   (path traversal is refused by construction: an id must match
///   `[A-Za-z0-9][A-Za-z0-9._-]*`, so it can never name `..`, an absolute
///   path, or a nested directory). The deterministic resolution:
///   1. `<root>/<id>/adapter.safetensors` when that exact file exists;
///   2. else the lexicographically-first `*.safetensors` file DIRECTLY
///      inside `<root>/<id>/` (a flat, non-recursive scan — one id can
///      never reach outside its own directory);
///   3. else null — the ref names nothing this machine has.
String? resolveLoraAdapterPath(String raw, {String? root}) {
  final value = raw.trim();
  if (value.isEmpty) return null;
  if (value.contains('/')) {
    if (value.startsWith('/')) {
      debugPrint('actor_brain: brainRef lora uses an absolute path: $value');
    }
    return value;
  }
  // Registry id shape guard: no separators, no traversal, not dot-names.
  final id = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*$').firstMatch(value);
  if (id == null || value == '.' || value == '..') return null;
  final base = Directory(
    root == null || root.isEmpty ? defaultLoraRoot() : root,
  );
  final dir = Directory('${base.path}/$value');
  final defaultFile = File('${dir.path}/$_registryAdapterFileName');
  if (defaultFile.existsSync()) return defaultFile.path;
  if (!dir.existsSync()) return null;
  final candidates =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.safetensors'))
          .map((f) => f.path)
          .toList()
        ..sort();
  return candidates.isEmpty ? null : candidates.first;
}

/// One palette rung's wire facts, as the Models surface discovered them
/// (G6): everything a `cast:` brain needs to speak, and nothing more —
/// the palette document stays the only source of models.
final class CastBrainDecl {
  const CastBrainDecl({
    required this.id,
    required this.model,
    required this.transport,
    this.baseUrl,
    this.credentialEnv,
    this.maxOutputTokens,
    this.reasoningEffort,
  });

  final String id;
  final String model;

  /// The palette transport wire name (`openrouter`, `openai_compatible`,
  /// `system_one`) or `builtin` for the composition root's local lanes.
  final String transport;
  final String? baseUrl;

  /// The environment VARIABLE name holding the credential (the palette
  /// never carries values).
  final String? credentialEnv;
  final int? maxOutputTokens;
  final String? reasoningEffort;

  bool get isBuiltinLocal =>
      transport == 'builtin' ||
      const {'qwen', 'lfm', 'apple_foundation_afm', 'laya', 'jev'}.contains(id);
}

/// Reads a credential the way a GUI-spawned process must: the process
/// environment first (a terminal-launched app inherits the shell), then
/// the harness's flat EnvConfig stores (global, then project-local) —
/// the same precedence chain the harness actor lanes use
/// (`xsoulspace_inference_core` EnvConfig). Values are never logged.
String? readInferenceCredential(
  final String envName, {
  final String? Function()? resolveHome,
  final Map<String, String>? environment,
}) {
  if (envName.isEmpty) return null;
  final env = environment ?? Platform.environment;
  final direct = env[envName];
  if (direct != null && direct.isNotEmpty) return direct;
  final home = resolveHome?.call() ?? env['HOME'] ?? env['USERPROFILE'];
  final candidates = <String>[
    if (home != null && home.isNotEmpty)
      '$home/.config/xsoulspace/inference/config.json',
    '.xsoulspace/config.json',
  ];
  for (final path in candidates) {
    try {
      final file = File(path);
      if (!file.existsSync()) continue;
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) continue;
      final value = decoded[envName];
      if (value is String && value.isNotEmpty) return value;
    } on Object {
      // An unreadable store is an absence, never a crash.
    }
  }
  return null;
}

/// Resolves a brainRef to a live brain, or null when the ref names
/// nothing this build can run.
///
/// [loraRoot] injects the loras registry root (tests point it at a
/// fixture directory); null means [defaultLoraRoot]. A REGISTRY-id lora
/// that resolves to nothing makes the whole ref null (the binding names
/// nothing); a filesystem-path lora is validated at attach time instead.
ActorBrain? resolveBrain(
  String brainRef, {
  required String? Function() resolveOpenRouterApiKey,
  String? loraRoot,
  CastBrainDecl? Function(String entryId)? resolveCast,
  String? Function(String envName)? resolveCredential,
}) {
  final ref = brainRef.trim();
  if (ref.startsWith('cast:')) {
    final entryId = ref.substring('cast:'.length).trim();
    if (entryId.isEmpty) return null;
    final decl = resolveCast?.call(entryId);
    if (decl == null) return null; // the palette names no such rung
    if (decl.isBuiltinLocal) {
      // A builtin cast IS the local lane: same engine, same law.
      return resolveBrain(
        'local:${decl.id}',
        resolveOpenRouterApiKey: resolveOpenRouterApiKey,
        loraRoot: loraRoot,
      );
    }
    final credentialEnv = decl.credentialEnv;
    return PaletteCastBrain(
      decl: decl,
      resolveApiKey: () => credentialEnv == null
          ? null
          : (resolveCredential ?? readInferenceCredential)(credentialEnv),
    );
  }
  final local = parseLocalBrainRef(ref);
  if (local != null) {
    if (!mlxSupported) return null;
    switch (local.cast) {
      case 'qwen' || 'lfm':
        break; // the default casts always resolve when MLX is supported
      default:
        // A named variant must exist in the hub cache — a binding to a
        // model this machine never cached names nothing.
        if (resolveQwen3SnapshotVariant(local.cast) == null) return null;
    }
    String? loraPath;
    if (local.lora != null) {
      loraPath = resolveLoraAdapterPath(local.lora!, root: loraRoot);
      if (loraPath == null) return null;
    }
    return _LocalCastBrain._(
      ref: ref,
      cast: local.cast,
      temperature: local.temperature ?? defaultChatTemperature,
      repetitionPenalty:
          local.repetitionPenalty ?? defaultChatRepetitionPenalty,
      loraPath: loraPath,
      loraScale: local.loraScale ?? 1.0,
    );
  }
  if (ref.startsWith('openrouter:')) {
    final model = ref.substring('openrouter:'.length).trim();
    if (model.isEmpty) {
      return null;
    }
    return OpenRouterBrain(
      model: model,
      resolveApiKey: resolveOpenRouterApiKey,
    );
  }
  return null;
}

/// The brain options the runtime can offer a creator right now.
///
/// Lists every cached Qwen3 variant the hub cache can discover (labeled
/// with its parameter count) next to the default casts. The variant scan
/// is injectable so tests never touch a real cache. `local:qwen` already
/// names the default 0.6B 4-bit snapshot, so that one variant is not
/// listed twice.
List<({String ref, String label})> availableBrainOptions({
  required String defaultOpenRouterModel,
  List<CachedQwen3Snapshot> Function()? discoverQwen3Variants,
  List<CastBrainDecl> paletteRungs = const [],
}) {
  final variants = discoverQwen3Variants != null
      ? discoverQwen3Variants()
      : (mlxSupported
            ? listCachedQwen3Snapshots()
            : const <CachedQwen3Snapshot>[]);
  return [
    if (mlxSupported) ...[
      (ref: 'local:qwen', label: 'Qwen3 · local (MLX)'),
      (ref: 'local:lfm', label: 'LFM 2.5 · local (MLX)'),
      for (final variant in variants)
        if (variant.refName != 'qwen3-0.6b')
          (
            ref: 'local:${variant.refName}',
            label: '${_qwen3VariantLabel(variant)} · local (MLX)',
          ),
    ],
    if (defaultOpenRouterModel.isNotEmpty) ...[
      (
        ref: 'openrouter:$defaultOpenRouterModel',
        label: 'OpenRouter · $defaultOpenRouterModel',
      ),
    ],
    // The discovered palette's generative rungs (G6): the world is the
    // source of models; the picker lists what it declares.
    for (final rung in paletteRungs)
      (ref: 'cast:${rung.id}', label: 'Palette · ${rung.id}'),
  ];
}

/// `qwen3-1.7b` → `Qwen3 1.7B`; `qwen3-0.6b-bf16` → `Qwen3 0.6B bf16`.
String _qwen3VariantLabel(CachedQwen3Snapshot variant) {
  final tail = variant.refName.substring('qwen3-'.length);
  final parts = tail.split('-');
  final size = parts.first.toUpperCase();
  final rest = parts.skip(1).join(' ');
  return rest.isEmpty ? 'Qwen3 $size' : 'Qwen3 $size $rest';
}

/// Local MLX casts are a macOS/Metal capability.
bool get mlxSupported => !kIsWeb && Platform.isMacOS;

/// Raised when a brain's engine or credential is absent.
final class BrainUnavailable implements Exception {
  const BrainUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'brain_unavailable: $reason';
}

/// Raised when a generate call fails.
final class BrainGenerationFailed implements Exception {
  const BrainGenerationFailed(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => 'brain_generation_failed: $code $message';
}

final class _LocalCastBrain implements ActorBrain {
  _LocalCastBrain._({
    required this.ref,
    required this.cast,
    required this.temperature,
    required this.repetitionPenalty,
    required this.loraPath,
    required this.loraScale,
  });

  @override
  final String ref;

  /// The cast name (after `local:`, before `?`).
  final String cast;
  final double temperature;
  final double repetitionPenalty;

  /// The RESOLVED adapter path (registry id or filesystem path through
  /// [resolveLoraAdapterPath]); null = the bare base weights. The isolate
  /// attaches it BEFORE the first generate that needs it and skips the
  /// re-attach while (path, scale) are unchanged.
  final String? loraPath;

  /// The adapter's final `alpha / r` multiplier ([resolveBrain] already
  /// applied the parse default).
  final double loraScale;

  @override
  String get label => switch (cast) {
    'qwen' => 'Qwen3 · local (MLX)',
    'lfm' => 'LFM 2.5 · local (MLX)',
    _ => () {
      final variant = listCachedQwen3Snapshots().firstWhere(
        (final c) => c.refName == cast,
        orElse: () => CachedQwen3Snapshot(
          refName: cast,
          paramLabel: cast,
          snapshotDir: '',
        ),
      );
      return '${_qwen3VariantLabel(variant)} · local (MLX)';
    }(),
  };

  @override
  Future<String> generate({
    required String system,
    required List<BrainTurn> turns,
  }) async {
    final reply = await _engineHost.generate(
      cast: cast,
      system: system,
      turns: turns,
      temperature: temperature,
      repetitionPenalty: repetitionPenalty,
      loraPath: loraPath,
      loraScale: loraScale,
    );
    return _checkedReply(reply);
  }
}

final class OpenRouterBrain implements ActorBrain {
  OpenRouterBrain({required this.model, required this._resolveApiKey});

  @override
  String get ref => 'openrouter:$model';

  @override
  String get label => 'OpenRouter · $model';

  /// OpenRouter model id (the part after the `openrouter:` prefix).
  final String model;
  final String? Function() _resolveApiKey;
  OpenRouterInferenceClient? _client;

  InferenceClient _effectiveClient() {
    final key = _resolveApiKey();
    if (key == null || key.isEmpty) {
      throw const BrainUnavailable('openrouter_api_key_missing');
    }
    return _client ??= OpenRouterInferenceClient(
      apiKey: key,
      defaultModel: model,
    );
  }

  @override
  Future<String> generate({
    required String system,
    required List<BrainTurn> turns,
  }) async {
    final result = await _effectiveClient().infer(
      _renderRequest(
        system: system,
        turns: turns,
        // Chat is not greedy anywhere: hosted casts get the same chat
        // temperature. The repetition penalty stays opt-in for hosted
        // models (they handle repetition natively; the echo evidence was
        // a local-cast fact).
        temperature: defaultChatTemperature,
        repetitionPenalty: null,
      ),
    );
    return _checkedResult(result);
  }
}

/// A palette rung as a conversational brain (G6): the openai-compatible
/// wire through the same client the OpenRouter lane uses, pointed at the
/// palette's endpoint. The credential is the palette's env NAME resolved
/// at generate time (a key rotated or added later takes effect without
/// re-resolving the brain); its absence is the typed [BrainUnavailable],
/// never a silent empty key.
final class PaletteCastBrain implements ActorBrain {
  PaletteCastBrain({
    required this.decl,
    required this.resolveApiKey,
    this.httpClient,
  });

  final CastBrainDecl decl;
  final String? Function() resolveApiKey;

  /// Test seam: the wire client under the OpenAI-compatible lane.
  final Object? httpClient;
  OpenRouterInferenceClient? _client;

  @override
  String get ref => 'cast:${decl.id}';

  @override
  String get label => 'Palette · ${decl.id}';

  InferenceClient _effectiveClient() {
    final key = resolveApiKey();
    if (key == null || key.isEmpty) {
      throw BrainUnavailable(
        'cast_credential_absent:${decl.credentialEnv ?? 'unnamed'}',
      );
    }
    return _client ??= OpenRouterInferenceClient(
      apiKey: key,
      defaultModel: decl.model,
      baseUrl: decl.baseUrl ?? 'https://openrouter.ai/api/v1',
      httpClient: httpClient as http.Client?,
    );
  }

  @override
  Future<String> generate({
    required String system,
    required List<BrainTurn> turns,
  }) async {
    final result = await _effectiveClient().infer(
      _renderRequest(
        system: system,
        turns: turns,
        temperature: defaultChatTemperature,
        repetitionPenalty: null,
      ),
    );
    return _checkedResult(result);
  }
}

/// Both wire shapes on one call: chat-native providers (the local MLX
/// casts) render `messages` through their own templates and ignore the
/// prompt; prompt-composing providers (OpenRouter) fold
/// `systemPrompt`+`prompt` and ignore `messages`. Each kind takes the
/// shape it speaks; neither double-renders.
InferenceRequest _renderRequest({
  required String system,
  required List<BrainTurn> turns,
  required double? temperature,
  required double? repetitionPenalty,
}) {
  final transcript = [
    for (final turn in turns)
      '${turn.fromMe ? 'you' : 'other'}: ${turn.content}',
  ].join('\n');
  return InferenceRequest(
    prompt: transcript.isEmpty
        ? 'Say your first message.'
        : '$transcript\nReply as one message.',
    systemPrompt: system,
    temperature: temperature,
    repetitionPenalty: repetitionPenalty,
    messages: [
      ChatMessage.system(system),
      for (final turn in turns)
        if (turn.fromMe)
          ChatMessage.assistant(turn.content)
        else
          ChatMessage.user(turn.content),
    ],
  );
}

/// Maps a wire result to text or the typed brain errors.
String _checkedResult(InferenceResult<InferenceResponse> result) {
  if (!result.success) {
    final error = result.error;
    throw BrainGenerationFailed(
      error?.code ?? 'unknown',
      error?.message ?? 'no message',
    );
  }
  return result.data?.rawOutput ?? '';
}

/// Maps the engine isolate's reply to text or the typed brain errors.
String _checkedReply(Map<String, Object?> reply) {
  if (reply['ok'] == true) return reply['text'] as String? ?? '';
  final code = '${reply['code'] ?? 'unknown'}';
  final message = '${reply['message'] ?? 'no message'}';
  if (reply['retryable'] == true) {
    // The lazy weight load (or the isolate itself) is not there yet —
    // the same typed unavailability the direct client used to answer.
    throw BrainUnavailable(message);
  }
  throw BrainGenerationFailed(code, message);
}

// ---------------------------------------------------------------------------
// The engine isolate: ONE long-lived background isolate owns the local MLX
// clients. Weights load THERE (the expensive FFI — the old shape blocked
// the UI isolate 20–60 s per first load), and every generate queues
// through the command port, so the isolate's event loop serializes them:
// two bots sharing one engine just queue, off the UI isolate entirely.
// ---------------------------------------------------------------------------

/// One generate request over the port protocol (plain sendable maps).
Map<String, Object?> _engineRequest({
  required int id,
  required String cast,
  required String system,
  required List<BrainTurn> turns,
  required double? temperature,
  required double? repetitionPenalty,
  String? loraPath,
  double loraScale = 1.0,
}) => <String, Object?>{
  'id': id,
  'op': 'generate',
  'cast': cast,
  'system': system,
  'turns': [
    for (final turn in turns)
      <String, Object?>{'fromMe': turn.fromMe, 'content': turn.content},
  ],
  'temperature': ?temperature,
  'repetitionPenalty': ?repetitionPenalty,
  'loraPath': ?loraPath,
  'loraScale': loraScale,
};

BrainTurn _turnFromJson(Object? raw) => switch (raw) {
  final Map raw => BrainTurn(
    fromMe: raw['fromMe'] == true,
    content: '${raw['content'] ?? ''}',
  ),
  _ => const BrainTurn(fromMe: false, content: ''),
};

/// The real cast factory (runs inside the engine isolate): lazy clients,
/// one per cast per isolate lifetime, so weights load once. A named
/// Qwen3 variant resolves its snapshot dir here, off the UI isolate.
InferenceClient _realCastClient(String cast) => switch (cast) {
  'qwen' => MlxNativeTextClient.lazyQwen(),
  'lfm' => MlxNativeTextClient.lazyLfm2(),
  _ => () {
    final dir = resolveQwen3SnapshotVariant(cast);
    if (dir == null) {
      throw BrainUnavailable('unknown_local_cast:$cast');
    }
    return MlxNativeTextClient.lazyQwen(snapshotDir: dir, model: cast);
  }(),
};

/// Serves generate — and runtime-LoRA attach — requests SERIALLY: messages
/// arrive on the command port, queue, and run one at a time — the native
/// engine's own serialization, kept explicit so the ordering law holds by
/// construction. THE ATTACH→GENERATE PAIRING is a property of that queue:
/// an `attachLora` command is one job; a generate that names a lora runs
/// its ensure-attached step INLINE, ahead of `client.infer`, inside the
/// same job — so no attach can interleave with the generate it feeds and
/// no generate can decode on the bare base while its adapter attaches.
/// (The Rust side additionally folds the adapter digest into the engine's
/// weight identity, so its exact-prefix pool drops bare-base entries by
/// itself — the Dart-side records here exist to SKIP the re-attach when
/// (path, scale) are unchanged, not to invalidate caches.)
/// Static and injectable so tests run the same loop with a fake engine
/// in-process (no isolate needed to test the protocol).
final class BrainEngineServer {
  BrainEngineServer._(this._replies, this._newClient);

  final SendPort _replies;
  final InferenceClient Function(String cast) _newClient;
  final _clients = <String, InferenceClient>{};

  /// The attached adapter per cast — the skip-when-unchanged record
  /// (path, scale, digest, applied). A freshly built client always runs
  /// the bare base, so building one drops the record and the next
  /// lora-bearing generate re-attaches.
  final _attachedLora =
      <String, ({String path, double scale, String digest, int applied})>{};
  final _queue = <Map<String, Object?>>[];
  var _draining = false;

  static void serve({
    required SendPort replies,
    required InferenceClient Function(String cast) newClient,
  }) {
    final server = BrainEngineServer._(replies, newClient);
    final port = RawReceivePort(server._onMessage);
    replies.send(port.sendPort);
  }

  void _onMessage(Object? message) {
    if (message is! Map) return;
    _queue.add(Map<String, Object?>.from(message));
    if (!_draining) {
      _draining = true;
      unawaited(_drain());
    }
  }

  Future<void> _drain() async {
    while (_queue.isNotEmpty) {
      final request = _queue.removeAt(0);
      _replies.send(await _handle(request));
    }
    _draining = false;
    // A request landing between the last emptiness check and this reset
    // would otherwise never drain: re-check under the reset.
    if (_queue.isNotEmpty && !_draining) {
      _draining = true;
      unawaited(_drain());
    }
  }

  Future<Map<String, Object?>> _handle(Map<String, Object?> request) async {
    final id = request['id'];
    if (id is! int) {
      return _badRequest(id, 'unsupported engine request');
    }
    switch (request['op']) {
      case 'attachLora':
        return _handleAttachLora(id, request);
      case 'generate':
        return _handleGenerate(id, request);
      default:
        return _badRequest(id, 'unsupported engine request');
    }
  }

  /// The `attachLora` command: eagerly attach (or re-confirm) the adapter
  /// for one cast, replying with the engine's attachment record (`digest`
  /// + `applied`) so a host can surface adapter state without generating.
  Future<Map<String, Object?>> _handleAttachLora(
    int id,
    Map<String, Object?> request,
  ) async {
    final path = request['loraPath'];
    if (path is! String || path.isEmpty) {
      return _badRequest(id, 'attachLora needs a loraPath');
    }
    try {
      final cast = '${request['cast'] ?? ''}';
      final client = _clientFor(cast);
      final attachment = await _ensureLoraAttached(
        cast,
        client,
        path,
        _scaleOf(request),
      );
      return <String, Object?>{
        'id': id,
        'ok': true,
        'digest': attachment.digest,
        'applied': attachment.applied,
      };
    } on BrainUnavailable catch (error) {
      return _engineFailure(id, 'unavailable', error.reason, retryable: true);
    } on NativeLoraAttachUnavailable {
      return _engineFailure(id, 'lora_abi_missing', _loraAbiMissingMessage);
    } on Object catch (error) {
      return _engineFailure(id, 'lora_attach_failed', '$error');
    }
  }

  Future<Map<String, Object?>> _handleGenerate(
    int id,
    Map<String, Object?> request,
  ) async {
    try {
      final cast = '${request['cast'] ?? ''}';
      final client = _clientFor(cast);
      // THE explicit attach→generate pairing (see the class docs): when
      // the request names an adapter, the ensure-attached step runs HERE —
      // serialized ahead of infer by the very queue that dispatched this
      // job — and a failed attach REFUSES the generate with a named error,
      // never a bare-base decode pretending the adapter rode along.
      final loraPath = request['loraPath'] as String?;
      if (loraPath != null) {
        try {
          await _ensureLoraAttached(cast, client, loraPath, _scaleOf(request));
        } on NativeLoraAttachUnavailable {
          return _engineFailure(id, 'lora_abi_missing', _loraAbiMissingMessage);
        } on BrainUnavailable catch (error) {
          return _engineFailure(
            id,
            'unavailable',
            error.reason,
            retryable: true,
          );
        } on BrainGenerationFailed catch (error) {
          return _engineFailure(id, error.code, error.message);
        } on Object catch (error) {
          return _engineFailure(id, 'lora_attach_failed', '$error');
        }
      }
      final result = await client.infer(
        _renderRequest(
          system: '${request['system'] ?? ''}',
          turns: [
            for (final raw in (request['turns'] as List? ?? const <Object?>[]))
              _turnFromJson(raw),
          ],
          temperature: switch (request['temperature']) {
            final num value => value.toDouble(),
            _ => null,
          },
          repetitionPenalty: switch (request['repetitionPenalty']) {
            final num value => value.toDouble(),
            _ => null,
          },
        ),
      );
      if (!result.success) {
        final error = result.error;
        return <String, Object?>{
          'id': id,
          'ok': false,
          'code': error?.code ?? 'unknown',
          'message': error?.message ?? 'no message',
          // The lazy weight load answers `unavailable` retryable —
          // surfaced to the caller as BrainUnavailable, everything else
          // as BrainGenerationFailed (the same split as before).
          'retryable': error?.code == 'unavailable',
        };
      }
      return <String, Object?>{
        'id': id,
        'ok': true,
        'text': result.data?.rawOutput ?? '',
      };
    } on BrainUnavailable catch (error) {
      return <String, Object?>{
        'id': id,
        'ok': false,
        'code': 'unavailable',
        'message': error.reason,
        'retryable': true,
      };
    } on Object catch (error) {
      return <String, Object?>{
        'id': id,
        'ok': false,
        'code': 'engine_error',
        'message': '$error',
        'retryable': false,
      };
    }
  }

  static double _scaleOf(Map<String, Object?> request) =>
      switch (request['loraScale']) {
        final num value => value.toDouble(),
        _ => 1.0,
      };

  /// Resolves (and builds, once) the client for one cast. Building one
  /// drops the cast's attach record: a fresh engine runs the bare base.
  InferenceClient _clientFor(String cast) => _clients.putIfAbsent(cast, () {
    _attachedLora.remove(cast);
    return _newClient(cast);
  });

  /// THE attach→generate seam: makes (path, scale) the attached adapter
  /// of [cast]'s engine and returns the attachment record. Skips the
  /// native attach when the record says it is already attached (the Rust
  /// side is idempotent on (digest, scale); the skip only avoids the
  /// redundant file-hash round trip — on-disk changes are picked up on
  /// the first attach that names a different path or scale, and an
  /// engine rebuild resets the record). Named refusals, never silent
  /// ignores: [NativeLoraAttachUnavailable] on a dylib without the ABI,
  /// [BrainGenerationFailed](`lora_unsupported_engine`) on an engine
  /// client without an attach surface, [BrainUnavailable] when the lazy
  /// weight load is not there yet, and the engine's own message
  /// otherwise (a bad adapter file, a target the checkpoint lacks).
  Future<NativeLoraAttachment> _ensureLoraAttached(
    String cast,
    InferenceClient client,
    String path,
    double scale,
  ) async {
    final recorded = _attachedLora[cast];
    if (recorded != null && recorded.path == path && recorded.scale == scale) {
      return NativeLoraAttachment(
        digest: recorded.digest,
        applied: recorded.applied,
      );
    }
    if (client is! LoraAttachableInferenceClient) {
      throw const BrainGenerationFailed(
        'lora_unsupported_engine',
        'the cast engine client has no runtime-LoRA attach surface',
      );
    }
    if (!client.loraAttachSupported) {
      throw const NativeLoraAttachUnavailable();
    }
    final attachment = await client.attachLora(path, scale: scale);
    _attachedLora[cast] = (
      path: path,
      scale: scale,
      digest: attachment.digest,
      applied: attachment.applied,
    );
    return attachment;
  }

  /// The named refusal an old dylib earns, surfaced verbatim.
  static const _loraAbiMissingMessage =
      'the loaded native dylib predates the lora attach ABI; the adapter '
      'was NOT applied (refresh the native assets to attach adapters)';

  Map<String, Object?> _badRequest(Object? id, String message) =>
      <String, Object?>{
        'id': id is int ? id : null,
        'ok': false,
        'code': 'bad_request',
        'message': message,
        'retryable': false,
      };

  Map<String, Object?> _engineFailure(
    int id,
    String code,
    String message, {
    bool retryable = false,
  }) => <String, Object?>{
    'id': id,
    'ok': false,
    'code': code,
    'message': message,
    'retryable': retryable,
  };
}

/// The host side of the engine isolate: one per app run, respawned lazily
/// after a crash. Requests correlate by id; an isolate death fails the
/// pending batch with a retryable [BrainUnavailable] and the next
/// generate brings the isolate (and weights) back.
final class _EngineIsolateHost {
  _EngineIsolateHost._();
  static final _EngineIsolateHost instance = _EngineIsolateHost._();

  final _pending = <int, Completer<Map<String, Object?>>>{};
  var _nextId = 1;
  SendPort? _enginePort;
  Completer<SendPort>? _starting;

  Future<Map<String, Object?>> generate({
    required String cast,
    required String system,
    required List<BrainTurn> turns,
    required double? temperature,
    required double? repetitionPenalty,
    String? loraPath,
    double loraScale = 1.0,
  }) async {
    final enginePort = await _ensureStarted();
    final id = _nextId++;
    final done = Completer<Map<String, Object?>>();
    _pending[id] = done;
    enginePort.send(
      _engineRequest(
        id: id,
        cast: cast,
        system: system,
        turns: turns,
        temperature: temperature,
        repetitionPenalty: repetitionPenalty,
        loraPath: loraPath,
        loraScale: loraScale,
      ),
    );
    return done.future;
  }

  Future<SendPort> _ensureStarted() {
    final live = _enginePort;
    if (live != null) return Future.value(live);
    final starting = _starting;
    if (starting != null) return starting.future;
    final ready = Completer<SendPort>();
    _starting = ready;
    final reply = RawReceivePort((final Object? message) {
      if (message is SendPort) {
        _enginePort = message;
        if (!ready.isCompleted) ready.complete(message);
      } else if (message is Map) {
        final id = switch (message['id']) {
          final int id => id,
          _ => null,
        };
        final pending = id == null ? null : _pending.remove(id);
        pending?.complete(Map<String, Object?>.from(message));
      }
    });
    void failStart(Object error) {
      reply.close();
      _enginePort = null;
      _starting = null;
      if (!ready.isCompleted) ready.completeError(error);
    }

    unawaited(
      Isolate.spawn(
        _engineIsolateMain,
        reply.sendPort,
        onExit: _exitPort()?.sendPort,
      ).then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) => failStart(error),
      ),
    );
    return ready.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        failStart(const BrainUnavailable('engine_isolate_start_timeout'));
        throw const BrainUnavailable('engine_isolate_start_timeout');
      },
    );
  }

  RawReceivePort? _exitPort() {
    final port = RawReceivePort((final Object? message) {
      // The engine isolate died: fail everything pending as retryable
      // unavailability; the next generate respawns it (weights reload).
      _enginePort = null;
      _starting = null;
      for (final pending in _pending.values) {
        pending.complete(
          _engineReply(
            id: null,
            code: 'engine_isolate_dead',
            message: 'the local engine isolate exited',
          ),
        );
      }
      _pending.clear();
    });
    return port;
  }
}

Map<String, Object?> _engineReply({
  required int? id,
  required String code,
  required String message,
  bool retryable = true,
}) => <String, Object?>{
  'id': ?id,
  'ok': false,
  'code': code,
  'message': message,
  'retryable': retryable,
};

/// The engine isolate's entry point.
@pragma('vm:entry-point')
void _engineIsolateMain(SendPort replies) {
  BrainEngineServer.serve(replies: replies, newClient: _realCastClient);
}

/// The shared engine host (one isolate per app run owns the local casts).
final _EngineIsolateHost _engineHost = _EngineIsolateHost.instance;
