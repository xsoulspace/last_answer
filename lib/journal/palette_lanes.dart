/// The lane families the harness composition root owns, mirrored
/// READ-ONLY (the collision law: LA edits neither the harness nor its
/// config — it mirrors closed vocabularies the same way
/// [kTransportWireNames] mirrors `PaletteTransport`).
///
/// `builtin: true` on a cast entry does NOT mean "local model": it means
/// "the composition root owns this binding" (the harness parser's
/// `builtinPaletteNames` law). The owned bindings ride DIFFERENT lanes —
/// mirrored here from the composition root's binding map
/// (`ecsai.dart`'s `generationResourceKeys` + `model_palette.dart`'s
/// entry docs, 2026-11-15):
///
/// * `lfm`, `qwen` — the local MLX native-engine casts (on-device);
/// * `laya` — the local System-One decision lane (loopback, no egress);
/// * `apple_foundation_afm` — Apple Foundation Models (on-device, but an
///   Apple-specific lane, not the MLX one);
/// * `jev`, `open_router` — the HOSTED OpenRouter lane (DeepSeek): a
///   remote brain, which the old `builtin == local` chip mislabelled.
///
/// A builtin name this mirror does not know renders `builtin` — an
/// honest unknown family, never a guessed one (a future harness builtin
/// must not inherit a false lane claim).
library;

import 'package:lastanswer/journal/actor_roster.dart';

/// The family of a composition-root built-in lane.
enum BuiltinLaneFamily {
  /// The local MLX native-engine casts (`lfm`, `qwen`).
  localMlx,

  /// The local System-One decision lane (`laya`, loopback).
  localDecision,

  /// Apple Foundation Models (`apple_foundation_afm`): on-device, but an
  /// Apple-specific lane — its own chip, never the generic `local`.
  appleFoundation,

  /// The hosted OpenRouter lane (`jev`, `open_router`): remote brains.
  hostedOpenRouter,

  /// A builtin name the mirror does not know: no lane claim at all.
  unknown,
}

/// The family a built-in cast id rides (the mirror of the composition
/// root's binding map; see the library doc).
BuiltinLaneFamily builtinLaneFamily(final String id) => switch (id) {
  'lfm' || 'qwen' => BuiltinLaneFamily.localMlx,
  'laya' => BuiltinLaneFamily.localDecision,
  'apple_foundation_afm' => BuiltinLaneFamily.appleFoundation,
  'jev' || 'open_router' => BuiltinLaneFamily.hostedOpenRouter,
  _ => BuiltinLaneFamily.unknown,
};

/// The lane chip's mono label: wire-ish names, like the transport chips —
/// `local` for the on-device native/loopback lanes, `afm` for the
/// Apple-specific one, `open_router` for the hosted lane, `builtin` for
/// an unknown family (never a guessed lane).
String builtinLaneChipLabel(final BuiltinLaneFamily family) => switch (family) {
  BuiltinLaneFamily.localMlx || BuiltinLaneFamily.localDecision => 'local',
  BuiltinLaneFamily.appleFoundation => 'afm',
  BuiltinLaneFamily.hostedOpenRouter => 'open_router',
  BuiltinLaneFamily.unknown => 'builtin',
};

/// Whether the family serves on this device with no external egress
/// (the `isLocal` law: the hosted lane is NOT local, and an unknown
/// builtin claims nothing).
bool builtinLaneIsLocal(final BuiltinLaneFamily family) =>
    family == BuiltinLaneFamily.localMlx ||
    family == BuiltinLaneFamily.localDecision ||
    family == BuiltinLaneFamily.appleFoundation;

/// The reasoning-effort tiers each DECLARED transport can carry,
/// mirrored from the production inference clients'
/// `supportedReasoningEfforts` (2026-11-15): the OpenRouter client
/// declares minimal…xhigh; the openai_compatible chat-completions client
/// and the local/AFM lanes declare NONE today, so a declaration on those
/// lanes refuses at dispatch as `reasoning_effort_unsupported` (the
/// harness router's named refusal). The Zed law rides this map: a model
/// whose lane declares no tiers gets NO reasoning controls — an honest
/// absence, not a disabled field — and the gap ask names the missing
/// client tiers (surface_gaps, 2026-11-15).
const Map<String, List<String>> kReasoningEffortTiers = <String, List<String>>{
  'openrouter': <String>['minimal', 'low', 'medium', 'high', 'xhigh'],
};

/// Reasoning tiers a subscription provider accepts, mirrored from the
/// clients (`OpenAiResponsesClient` none…xhigh, `GrokResponsesClient`
/// low/medium/high). Keyed by provider id, not by palette transport.
const Map<String, List<String>> kSubscriptionReasoningTiers =
    <String, List<String>>{
      'openai_chatgpt_plan': <String>[
        'none',
        'minimal',
        'low',
        'medium',
        'high',
        'xhigh',
      ],
      'xai_grok_plan': <String>['low', 'medium', 'high'],
    };

/// The display titles of the tier wire values (Zed's shared
/// `ReasoningEffort` labels: `xhigh` reads "Extra High", never "xhigh").
/// A declared value outside the mirror keeps its wire name.
const Map<String, String> kReasoningEffortTitles = <String, String>{
  'minimal': 'Minimal',
  'low': 'Low',
  'medium': 'Medium',
  'high': 'High',
  'xhigh': 'Extra High',
  'max': 'Max',
};

/// The readable title of a declared (or picked) effort wire value.
String reasoningEffortTitle(final String wire) =>
    kReasoningEffortTitles[wire] ?? wire;

/// The owner's four lane classes (2026-11-16): the product vocabulary
/// the Models surface speaks — NOT the harness's wire names, and NOT
/// the builtin-name mirror (which stays internal to resolve them).
enum LaneClass {
  /// A declared remote endpoint (modelscope, openrouter, …).
  remote,

  /// A declared provider whose endpoint is THIS machine (ollama-class
  /// lanes ride the openai_compatible wire over loopback).
  localServer,

  /// A subscription provider (the ChatGPT plan, the Grok plan). Actors
  /// address it as `subscription:<providerId>/<model>` (ADR 0031). It
  /// is not a harness palette transport.
  subscription,

  /// An on-device built-in service (AFM, laya, the MLX casts).
  onDevice,

  /// A builtin name the mirror does not know: no class claim.
  unclassified,
}

/// The chip label per class (mono, wire-ish, like the transport chips).
String laneClassChipLabel(final LaneClass laneClass) => switch (laneClass) {
  LaneClass.remote => 'remote',
  LaneClass.localServer => 'loopback',
  LaneClass.subscription => 'subscription',
  LaneClass.onDevice => 'on-device',
  LaneClass.unclassified => 'builtin',
};

/// Whether a declared endpoint is this machine (the harness allows
/// plain http ONLY on loopback, so a loopback base_url is a local
/// server by the parser's own law).
bool isLoopbackEndpoint(final String baseUrl) {
  final url = baseUrl.trim();
  return url.contains('://127.') ||
      url.contains('://localhost') ||
      url.contains('://[::1]');
}

/// The class of a DECLARED provider (transport + endpoint law).
LaneClass classOfProvider(final String transport, final String baseUrl) =>
    isLoopbackEndpoint(baseUrl) ? LaneClass.localServer : LaneClass.remote;

/// The class of a composition-root builtin (through the lane mirror).
LaneClass classOfBuiltin(final BuiltinLaneFamily family) => switch (family) {
  BuiltinLaneFamily.localMlx ||
  BuiltinLaneFamily.localDecision ||
  BuiltinLaneFamily.appleFoundation => LaneClass.onDevice,
  BuiltinLaneFamily.hostedOpenRouter => LaneClass.remote,
  BuiltinLaneFamily.unknown => LaneClass.unclassified,
};

/// The user-facing model name (the brain-policy vocabulary law,
/// 2026-11-16: no palette words on user surfaces). The declared model id
/// speaks its last path segment with dashes/underscores as spaces —
/// `modelscope/Qwen-Amassador/Qwen3.7-Plus` reads "Qwen3.7 Plus" — and a
/// `:free` suffix survives (it is a real tier fact). A row with no
/// declared model speaks its entry id (`apple_foundation_afm` reads
/// "Apple Foundation AFM") — never a raw snake_case id on a user
/// surface. The raw entry id stays the mono subtitle wherever agents
/// need the stable handle.
String brainModelLabel({required final String id, final String? model}) {
  final declared = model?.trim();
  final source = (declared == null || declared.isEmpty) ? id : declared;
  final segment = source.contains('/') ? source.split('/').last : source;
  final spoken = segment.replaceAll('-', ' ').replaceAll('_', ' ').trim();
  if (spoken.isEmpty) return id;
  return spoken.split(' ').map(_spokenToken).join(' ');
}

/// Title-cases one spoken token. Tokens already carrying an uppercase
/// letter keep their author's casing (`Qwen3.7`, `LFM`, `Plus`); known
/// hardware acronyms upper-case (`afm` → `AFM`); everything else
/// capitalizes (`apple` → `Apple`, `qwen` → `Qwen`).
String _spokenToken(final String token) {
  if (token.contains(RegExp('[A-Z]'))) return token;
  const acronyms = {'afm', 'lfm', 'llm', 'gpt', 'api', 'mlx'};
  if (acronyms.contains(token.toLowerCase())) return token.toUpperCase();
  if (token.isEmpty) return token;
  return '${token[0].toUpperCase()}${token.substring(1)}';
}

/// The reasoning tiers a BRAIN REF can carry (wave N2, the per-actor
/// half of the Zed law): local brains declare none; an `openrouter:`
/// brain rides the openrouter tiers; a `cast:` rung rides its
/// provider's transport wire name through [transportOfRung] (null =
/// the composition root's builtin: the hosted open_router lane has
/// tiers, on-device lanes none). This mirror stays host-import-free so
/// the brain lane never couples to the harness package.
List<String> reasoningTiersForBrainRef(
  final String brainRef, {
  required final String? Function(String rungId) transportOfRung,
}) {
  final base = brainRefBase(brainRef);
  if (base.startsWith('openrouter:')) {
    return kReasoningEffortTiers['openrouter'] ?? const <String>[];
  }
  if (base.startsWith(subscriptionBrainScheme)) {
    final parsed = parseSubscriptionBrainRef(base);
    if (parsed == null) return const <String>[];
    return kSubscriptionReasoningTiers[parsed.providerId] ?? const <String>[];
  }
  if (base.startsWith('cast:')) {
    final rungId = base.substring('cast:'.length);
    final transport = transportOfRung(rungId);
    if (transport == null) {
      return builtinLaneFamily(rungId) == BuiltinLaneFamily.hostedOpenRouter
          ? (kReasoningEffortTiers['openrouter'] ?? const <String>[])
          : const <String>[];
    }
    return kReasoningEffortTiers[transport] ?? const <String>[];
  }
  return const <String>[];
}
