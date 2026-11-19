import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:lastanswer/data_agents/config/image_generation_service.dart';
import 'package:lastanswer/data_agents/product/product_cloud_resource.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

void main() {
  group('ProductCloudImagesClient (the budget wire images lane)', () {
    test('a generation reserves n×ceiling and settles on usage.cost',
        () async {
      final dir = await Directory.systemTemp.createTemp('cloud-images-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final budget = ProductCloudBudget(File('${dir.path}/ledger.json'));
      final client = ProductCloudImagesClient(
        apiKey: 'sk-test',
        budget: budget,
        httpClient: _mockImagesEndpoint(
          body: jsonEncode({
            'data': [
              {'b64_json': 'aGVsbG8='},
            ],
            'usage': {'cost': 0.08},
          }),
        ),
      );
      addTearDown(client.close);

      final result = await client.infer(
        InferenceRequest.textToImage(
          prompt: 'a lighthouse',
          imageOptions: const InferenceImageOptions(n: 2),
          metadata: <String, dynamic>{'model': 'google/nano-banana-2'},
        ),
      );

      expect(result.success, isTrue);
      expect(result.data!.imageArtifacts, hasLength(1));
      // The reservation: 2 × $0.25, settled to the provider's own cost.
      expect(budget.spent, closeTo(0.08, 1e-9));
      expect(budget.pending, 0);
      expect(budget.unknown, isFalse);
      final dispatch = budget.events
          .firstWhere((event) => event['phase'] == 'cloud_dispatch');
      expect(dispatch['lane'], 'images');
      expect(dispatch['images'], 2);
    });

    test('a generation body naming the CHAT model is a mismatch, not a '
        'fallback', () async {
      final dir = await Directory.systemTemp.createTemp('cloud-images-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final budget = ProductCloudBudget(File('${dir.path}/ledger.json'));
      final client = ProductCloudImagesClient(
        apiKey: 'sk-test',
        budget: budget,
        httpClient: _neverReached,
      );
      addTearDown(client.close);

      // The wire refusal surfaces through the transport's failure shape
      // (the wire throws; the client maps it), never a silent fallback.
      final result = await client.infer(
        InferenceRequest.textToImage(
          prompt: 'a lighthouse',
          metadata: <String, dynamic>{
            'model': 'deepseek/deepseek-v4.1-flash-1017',
          },
        ),
      );
      expect(result.success, isFalse);
      expect(result.error?.code, 'engine_unavailable');
      expect(
        result.error?.details.toString(),
        contains('comparison_model_mismatch'),
      );
      // The refusal happened BEFORE any reservation.
      expect(budget.pending, 0);
    });

    test('the images lane never injects the chat price vocabulary', () async {
      final dir = await Directory.systemTemp.createTemp('cloud-images-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final budget = ProductCloudBudget(File('${dir.path}/ledger.json'));
      Map<String, dynamic>? wire;
      final client = ProductCloudImagesClient(
        apiKey: 'sk-test',
        budget: budget,
        httpClient: _mockImagesEndpoint(
          body: jsonEncode({
            'data': [
              {'b64_json': 'aGVsbG8='},
            ],
            'usage': {'cost': 0.08},
          }),
          onRequest: (request) =>
              wire = jsonDecode(request.body) as Map<String, dynamic>,
        ),
      );
      addTearDown(client.close);

      final result = await client.infer(
        InferenceRequest.textToImage(
          prompt: 'a lighthouse',
          metadata: <String, dynamic>{'model': 'google/nano-banana-2'},
        ),
      );

      expect(result.success, isTrue);
      final sent = wire;
      expect(sent, isNotNull);
      // The chat-lane injection must not ride an image body.
      expect(sent!.containsKey('provider'), isFalse);
      expect(sent.containsKey('messages'), isFalse);
      expect(sent['prompt'], 'a lighthouse');
    });
  });

  group('ImageGenerationService', () {
    test('refuses a client that declares no image tasks', () async {
      final dir = await Directory.systemTemp.createTemp('image-svc-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final service = ImageGenerationService(
        client: _ChatOnlyClient(),
        artifactsDirectory: Directory(dir.path),
      );
      final result = await service.generate(prompt: 'a lighthouse');
      expect(result.success, isFalse);
      expect(result.error?.code, 'client_lacks_image_tasks');
      service.dispose();
    });

    test('materializes b64 and url artifacts; a local filePath passes '
        'through', () async {
      final dir = await Directory.systemTemp.createTemp('image-svc-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final downloads = http_testing.MockClient((request) async {
        if (request.url.host == 'cdn.example.com') {
          return http.Response('webp!', 200);
        }
        return http.Response('gone', 410);
      });
      final service = ImageGenerationService(
        client: _ImageClient(
          response: const InferenceResponse(
            task: InferenceTask.textToImage,
            warnings: <String>['image_url_expiring'],
            imageArtifacts: <InferenceImageArtifact>[
              InferenceImageArtifact(
                mimeType: 'image/png',
                bytesBase64: 'aGVsbG8=',
              ),
              InferenceImageArtifact(
                mimeType: 'image/webp',
                url: 'https://cdn.example.com/out/abc.webp',
              ),
              InferenceImageArtifact(
                mimeType: 'image/png',
                filePath: '/tmp/local-engine-out.png',
              ),
            ],
          ),
        ),
        artifactsDirectory: Directory(dir.path),
        httpClient: downloads,
      );

      final result = await service.generate(
        prompt: 'a lighthouse',
        model: 'google/nano-banana-2',
      );

      expect(result.success, isTrue);
      final outcome = result.data!;
      expect(outcome.images, hasLength(3));
      expect(outcome.warnings, contains('image_url_expiring'));
      final first = File(outcome.images[0].filePath);
      expect(first.readAsStringSync(), 'hello');
      expect(outcome.images[0].filePath.endsWith('.png'), isTrue);
      final second = File(outcome.images[1].filePath);
      expect(second.readAsStringSync(), 'webp!');
      expect(outcome.images[1].filePath.endsWith('.webp'), isTrue);
      expect(outcome.images[2].filePath, '/tmp/local-engine-out.png');
      service.dispose();
    });

    test('a failed URL download refuses by name (expiring links)', () async {
      final dir = await Directory.systemTemp.createTemp('image-svc-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final service = ImageGenerationService(
        client: _ImageClient(
          response: const InferenceResponse(
            task: InferenceTask.textToImage,
            imageArtifacts: <InferenceImageArtifact>[
              InferenceImageArtifact(
                mimeType: 'image/png',
                url: 'https://expired.example.com/gone.png',
              ),
            ],
          ),
        ),
        artifactsDirectory: Directory(dir.path),
        httpClient: http_testing.MockClient(
          (_) async => http.Response('gone', 410),
        ),
      );

      final result = await service.generate(prompt: 'a lighthouse');
      expect(result.success, isFalse);
      expect(result.error?.code, 'artifact_download_failed');
      service.dispose();
    });
  });
}

/// A mock inner transport for the budget wire: it answers ONLY an images
/// body (prompt, no messages) naming the image model — anything else is a
/// test bug and returns a 500 so the mismatch surfaces.
http.Client _mockImagesEndpoint({
  required String body,
  void Function(http.Request request)? onRequest,
}) => http_testing.MockClient((request) async {
  onRequest?.call(request);
  return http.Response(body, 200);
});

final http.Client _neverReached = http_testing.MockClient((request) async {
  throw StateError('the mismatch must refuse before any HTTP');
});

/// A chat-only fake client (the honest refusal path).
final class _ChatOnlyClient implements InferenceClient {
  @override
  String get id => 'chat-only-fake';
  @override
  bool get isAvailable => true;
  @override
  Set<InferenceTask> get supportedTasks => const {InferenceTask.text};
  @override
  Future<void> load() async {}
  @override
  Future<bool> refreshAvailability() async => true;
  @override
  void resetAvailabilityCache() {}
  @override
  Future<InferenceResult<InferenceResponse>> infer(
    InferenceRequest request, {
    ToolRegistry? toolRegistry,
  }) async => InferenceResult<InferenceResponse>.fail(
    code: 'task_unsupported',
    message: 'chat only',
  );
}

/// A fake image client returning a canned response.
final class _ImageClient implements InferenceClient {
  _ImageClient({required this.response});

  final InferenceResponse response;
  @override
  String get id => 'image-fake';
  @override
  bool get isAvailable => true;
  @override
  Set<InferenceTask> get supportedTasks => const {
    InferenceTask.textToImage,
    InferenceTask.imageToImage,
  };
  @override
  Future<void> load() async {}
  @override
  Future<bool> refreshAvailability() async => true;
  @override
  void resetAvailabilityCache() {}
  @override
  Future<InferenceResult<InferenceResponse>> infer(
    InferenceRequest request, {
    ToolRegistry? toolRegistry,
  }) async => InferenceResult<InferenceResponse>.ok(response);
}
