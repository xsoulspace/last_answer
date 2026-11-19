import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_openrouter/xsoulspace_inference_openrouter.dart';

/// One comparison budget shared by every actor/document, retained on restart.
/// Pending/unknown bills retain their reservation and seal further admission.
final class ProductCloudBudget {
  ProductCloudBudget(this.file) {
    if (file.existsSync()) {
      final saved = jsonDecode(file.readAsStringSync()) as Map;
      final priorLimit = (saved['limitUsd'] as num).toDouble();
      if (priorLimit < limit) limit = priorLimit;
      spent = (saved['spent'] as num).toDouble();
      pending = (saved['pending'] as num).toDouble();
      unknown = saved['unknown'] == true || pending > 0;
    }
  }
  final File file;
  double spent = 0;
  double pending = 0;
  bool unknown = false;
  double limit = 1;
  final events = <Map<String, Object?>>[];
  void _save() {
    file.parent.createSync(recursive: true);
    File('${file.path}.tmp')
      ..writeAsStringSync(jsonEncode(summary), flush: true)
      ..renameSync(file.path);
  }

  Map<String, Object?> get summary => {
    'limitUsd': limit,
    'spent': spent,
    'pending': pending,
    'unknown': unknown,
  };
  double reserve(int bytes, int tokens) {
    // Token count cannot exceed UTF-8 bytes; margin covers protocol overhead.
    // Provider price ceilings are sent on the exact outgoing request below.
    final bound = (bytes + 4096) / 1e6 + tokens * 5 / 1e6;
    if (unknown || spent + pending + bound > limit) {
      throw StateError('product_cloud_budget_exhausted_or_unknown');
    }
    pending += bound;
    _save();
    return bound;
  }

  /// The IMAGE reservation: per-image, all-or-nothing billing (the
  /// provider either bills the generation whole or returns it free —
  /// there is no partial image), so the bound is
  /// [count] × [imagePriceCeilingUsd] and the settle reads the provider's
  /// own `usage.cost`.
  double reserveImages(int count) {
    final bound = count * imagePriceCeilingUsd;
    if (unknown || spent + pending + bound > limit) {
      throw StateError('product_cloud_budget_exhausted_or_unknown');
    }
    pending += bound;
    _save();
    return bound;
  }

  void settle(double bound, double? cost) {
    pending = (pending - bound).clamp(0.0, double.infinity);
    if (cost == null || !cost.isFinite || cost < 0 || cost > bound) {
      unknown = true;
      pending += bound;
    } else {
      spent += cost;
    }
    _save();
    events.add({'phase': 'cloud_billing', 'costUsd': cost, ...summary});
  }
}

/// The conservative per-image ceiling the reservation uses before the
/// provider's own cost arrives (measured docs range 2026-11-15: $0.05
/// Seedream 4.5 → $0.13 gpt-image-2 high; the ceiling sits above both).
const double imagePriceCeilingUsd = 0.25;

final class _BudgetWire extends http.BaseClient {
  _BudgetWire(this.budget, {this.imageModel, http.Client? httpClient})
    : inner = httpClient ?? http.Client();
  final ProductCloudBudget budget;

  /// The image model id the wire serves on the images lane, or null when
  /// this wire carries chat bodies only. The images body is detected by
  /// its own shape (a `prompt`, no `messages`).
  final String? imageModel;
  final http.Client inner;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) {
      throw StateError('unsupported_billing_request');
    }
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final isImageRequest =
        body.containsKey('prompt') && !body.containsKey('messages');
    if (isImageRequest) {
      return _sendImage(request, body);
    }
    if (body['model'] != ProductCloudClient.model) {
      throw StateError('comparison_model_mismatch');
    }
    final tokens = body['max_tokens'];
    if (tokens is! int || tokens <= 0) {
      throw StateError('bounded_output_required');
    }
    body['provider'] = {
      'require_parameters': true,
      'max_price': {'prompt': 1, 'completion': 5},
    };
    request.body = jsonEncode(body);
    final bound = budget.reserve(request.bodyBytes.length, tokens);
    final watch = Stopwatch()..start();
    budget.events.add({
      'phase': 'cloud_dispatch',
      'model': body['model'],
      'reservedUsd': bound,
    });
    try {
      final response = await inner.send(request);
      final bytes = await response.stream.toBytes();
      final value = jsonDecode(utf8.decode(bytes)) as Map;
      budget.events.add({
        'phase': 'cloud_receipt',
        'model': value['model'],
        'provider': value['provider'],
        'id': value['id'],
        'elapsedMs': watch.elapsedMilliseconds,
      });
      final usage = value['usage'];
      final cost = usage is Map ? usage['cost'] : null;
      budget.settle(bound, cost is num ? cost.toDouble() : null);
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    } on Object {
      budget.settle(bound, null);
      rethrow;
    }
  }

  /// The images lane: per-image all-or-nothing billing, no chat price
  /// injection (the `provider.max_price` vocabulary is chat-lane), the
  /// settle reads the provider's own `usage.cost`.
  Future<http.StreamedResponse> _sendImage(
    http.Request request,
    Map<String, dynamic> body,
  ) async {
    if (imageModel == null || body['model'] != imageModel) {
      throw StateError('comparison_model_mismatch');
    }
    // An absent count defaults to 1 (the provider default); an explicitly
    // invalid count refuses — the bound must stay honest.
    final rawCount = body['n'];
    final int count;
    if (rawCount == null) {
      count = 1;
    } else if (rawCount is int && rawCount >= 1 && rawCount <= 10) {
      count = rawCount;
    } else {
      throw StateError('bounded_image_count_required');
    }
    final bound = budget.reserveImages(count);
    final watch = Stopwatch()..start();
    budget.events.add({
      'phase': 'cloud_dispatch',
      'lane': 'images',
      'model': body['model'],
      'images': count,
      'reservedUsd': bound,
    });
    try {
      final response = await inner.send(request);
      final bytes = await response.stream.toBytes();
      final value = jsonDecode(utf8.decode(bytes)) as Map;
      budget.events.add({
        'phase': 'cloud_receipt',
        'lane': 'images',
        'model': value['model'],
        'id': value['id'],
        'elapsedMs': watch.elapsedMilliseconds,
      });
      final usage = value['usage'];
      final cost = usage is Map ? usage['cost'] : null;
      budget.settle(bound, cost is num ? cost.toDouble() : null);
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    } on Object {
      // A failed generation bills nothing (all-or-nothing), but the
      // provider's silence is still unknown billing — the honest seal.
      budget.settle(bound, null);
      rethrow;
    }
  }

  @override
  void close() => inner.close();
}

/// Cancellation is per request/actor, never a shared provider credential.
final class ProductCloudClient implements CancellableInferenceClient {
  ProductCloudClient({required this.apiKey, required this.budget});
  final String apiKey;
  final ProductCloudBudget budget;
  static const model = 'deepseek/deepseek-v4.1-flash-1017';
  final _active = <_BudgetWire>{};
  final _pending = <Future<InferenceResult<InferenceResponse>>>{};
  int _epoch = 0;
  bool _closed = false;
  @override
  String get id => model;
  @override
  bool get isAvailable => !_closed && apiKey.isNotEmpty && !budget.unknown;
  @override
  Set<InferenceTask> get supportedTasks => {
    InferenceTask.text,
    InferenceTask.nativelyStructuredText,
  };
  @override
  Future<void> load() async {}
  @override
  Future<bool> refreshAvailability() async => isAvailable;
  @override
  void resetAvailabilityCache() {}
  @override
  Future<InferenceResult<InferenceResponse>> infer(
    InferenceRequest request, {
    ToolRegistry? toolRegistry,
  }) {
    final epoch = _epoch;
    if (!isAvailable) {
      return Future.value(
        InferenceResult.fail(
          code: 'cloud_unavailable',
          message: 'Cloud resource unavailable',
        ),
      );
    }
    final wire = _BudgetWire(budget);
    _active.add(wire);
    final client = OpenRouterInferenceClient(
      apiKey: apiKey,
      defaultModel: model,
      httpClient: wire,
    );
    late Future<InferenceResult<InferenceResponse>> future;
    future = client
        .infer(request, toolRegistry: toolRegistry)
        .then(
          (result) => epoch == _epoch && !_closed
              ? result
              : InferenceResult<InferenceResponse>.fail(
                  code: 'cancelled',
                  message: 'Cloud response discarded after Stop',
                ),
        )
        .whenComplete(() {
          _active.remove(wire);
          wire.close();
          _pending.remove(future);
        });
    _pending.add(future);
    return future;
  }

  @override
  void cancelActive() {
    _epoch++;
    for (final wire in _active.toList()) {
      wire.close();
    }
  }

  @override
  Future<void> settleActive() async {
    await Future.wait(_pending.toList());
  }

  @override
  void close() {
    _closed = true;
    cancelActive();
  }
}

/// The cloud IMAGE client: the OpenRouter images lane under the same
/// comparison budget. The wire's images branch requires an explicit
/// `imageModel` (a generation body for the chat model is a mismatch, not
/// a fallback) and an image count bound 1-10.
final class ProductCloudImagesClient implements CancellableInferenceClient {
  ProductCloudImagesClient({
    required this.apiKey,
    required this.budget,
    this.imageModel = 'google/nano-banana-2',
    this._httpClient,
  });
  final String apiKey;
  final ProductCloudBudget budget;
  final String imageModel;
  final http.Client? _httpClient;
  final _active = <_BudgetWire>{};
  final _pending = <Future<InferenceResult<InferenceResponse>>>{};
  int _epoch = 0;
  bool _closed = false;
  @override
  String get id => imageModel;
  @override
  bool get isAvailable => !_closed && apiKey.isNotEmpty && !budget.unknown;
  @override
  Set<InferenceTask> get supportedTasks => const {
    InferenceTask.textToImage,
    InferenceTask.imageToImage,
  };
  @override
  Future<void> load() async {}
  @override
  Future<bool> refreshAvailability() async => isAvailable;
  @override
  void resetAvailabilityCache() {}
  @override
  Future<InferenceResult<InferenceResponse>> infer(
    InferenceRequest request, {
    ToolRegistry? toolRegistry,
  }) {
    final epoch = _epoch;
    if (!isAvailable) {
      return Future.value(
        InferenceResult.fail(
          code: 'cloud_unavailable',
          message: 'Cloud image resource unavailable',
        ),
      );
    }
    final wire = _BudgetWire(
      budget,
      imageModel: imageModel,
      httpClient: _httpClient,
    );
    _active.add(wire);
    final client = OpenRouterInferenceClient(
      apiKey: apiKey,
      defaultModel: imageModel,
      httpClient: wire,
      imageEndpointStyle: ImageEndpointStyle.openRouterImages,
    );
    late Future<InferenceResult<InferenceResponse>> future;
    future = client
        .infer(request)
        .then(
          (result) => epoch == _epoch && !_closed
              ? result
              : InferenceResult<InferenceResponse>.fail(
                  code: 'cancelled',
                  message: 'Cloud image response discarded after Stop',
                ),
        )
        .whenComplete(() {
          _active.remove(wire);
          wire.close();
          _pending.remove(future);
        });
    _pending.add(future);
    return future;
  }

  @override
  void cancelActive() {
    _epoch++;
    for (final wire in _active.toList()) {
      wire.close();
    }
  }

  @override
  Future<void> settleActive() async {
    await Future.wait(_pending.toList());
  }

  @override
  void close() {
    _closed = true;
    cancelActive();
  }
}
