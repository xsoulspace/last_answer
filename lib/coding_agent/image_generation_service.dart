import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lastanswer/coding_agent/product_cloud_resource.dart';
import 'package:lastanswer/coding_agent/product_local_pair.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

/// One generated image materialized to disk. The service is the ONLY
/// consumer-facing seam over the routed image client (the palette
/// declares the rows; the composition picks the client — the budget-wired
/// cloud lane, or a loopback local lane): callers hand it a prompt (+ an
/// optional reference image for image-to-image) and receive file paths in
/// the app's own storage (privacy-first: generated pixels stay local).
final class GeneratedImage {
  const GeneratedImage({required this.filePath, required this.mimeType});

  /// Absolute path of the materialized file (or the local engine's own
  /// file, passed through).
  final String filePath;
  final String mimeType;
}

/// The result of one generation: the materialized images plus the
/// response's own honest warnings (e.g. `image_url_expiring` — already
/// downloaded here, but the warning is the receipt).
final class ImageGenerationOutcome {
  const ImageGenerationOutcome({
    required this.images,
    this.warnings = const <String>[],
    this.meta = const <String, dynamic>{},
  });

  final List<GeneratedImage> images;
  final List<String> warnings;
  final Map<String, dynamic> meta;
}

/// A thin service over an [InferenceClient] that declares the image
/// tasks. No routing, no palette, no UI claims — the caller composes the
/// client (cloud budget lane, local loopback lane) and the artifacts
/// directory.
final class ImageGenerationService {
  ImageGenerationService({
    required this._client,
    required this.artifactsDirectory,
    http.Client? httpClient,
  }) : _ownsHttpClient = httpClient == null,
       _httpClient = httpClient ?? http.Client();

  final InferenceClient _client;
  final Directory artifactsDirectory;
  final http.Client _httpClient;
  final bool _ownsHttpClient;

  /// Whether the composed client can serve images at all — the palette's
  /// capability declaration read back through the client's own task gate.
  bool get canGenerateImages =>
      _client.supportedTasks.contains(InferenceTask.textToImage) ||
      _client.supportedTasks.contains(InferenceTask.imageToImage);

  /// One generation. Text-to-image with a null [reference]; image-to-image
  /// with one. The [model] rides the request metadata (the routed
  /// per-request model law) — null keeps the client's own default.
  Future<InferenceResult<ImageGenerationOutcome>> generate({
    required String prompt,
    InferenceImageInput? reference,
    InferenceImageOptions? options,
    String? model,
  }) async {
    if (!canGenerateImages) {
      return InferenceResult<ImageGenerationOutcome>.fail(
        code: 'client_lacks_image_tasks',
        message:
            '${_client.id} does not declare the image tasks — declare '
            '`image_generation` on the model row and re-compose',
      );
    }
    final base = reference == null
        ? InferenceRequest.textToImage(prompt: prompt, imageOptions: options)
        : InferenceRequest.imageToImage(
            prompt: prompt,
            imageInput: reference,
            imageOptions: options,
          );
    // The routed per-request model law: the model id rides the request
    // metadata; null keeps the client's own declared default.
    final request = model == null
        ? base
        : base.copyWith(metadata: <String, dynamic>{'model': model});
    final result = await _client.infer(request);
    if (!result.success) {
      return InferenceResult<ImageGenerationOutcome>.fail(
        code: result.error?.code ?? 'generation_failed',
        message: result.error?.message ?? 'Image generation failed',
        details: result.error?.details,
        meta: result.meta,
      );
    }
    final response = result.data!;
    if (response.imageArtifacts.isEmpty) {
      return InferenceResult<ImageGenerationOutcome>.fail(
        code: 'no_artifacts',
        message: 'The provider returned no image artifacts',
        meta: result.meta,
      );
    }
    try {
      final images = <GeneratedImage>[];
      var index = 0;
      for (final artifact in response.imageArtifacts) {
        images.add(await _materialize(artifact, index));
        index++;
      }
      return InferenceResult<ImageGenerationOutcome>.ok(
        ImageGenerationOutcome(
          images: images,
          warnings: response.warnings,
          meta: result.meta,
        ),
      );
    } on ImageArtifactException catch (error) {
      return InferenceResult<ImageGenerationOutcome>.fail(
        code: error.code,
        message: error.message,
        meta: result.meta,
      );
    }
  }

  /// One artifact → one local file. b64 decodes; a URL downloads
  /// PROMPTLY (expiring links); a local engine's filePath passes through.
  Future<GeneratedImage> _materialize(
    InferenceImageArtifact artifact,
    int index,
  ) async {
    if ((artifact.filePath ?? '').trim().isNotEmpty) {
      return GeneratedImage(
        filePath: artifact.filePath!,
        mimeType: artifact.mimeType,
      );
    }
    final bytesBase64 = artifact.bytesBase64;
    if (bytesBase64 != null && bytesBase64.isNotEmpty) {
      return GeneratedImage(
        filePath: await _write(
          base64Decode(bytesBase64),
          artifact.mimeType,
          index,
        ),
        mimeType: artifact.mimeType,
      );
    }
    final url = artifact.url;
    if (url != null && url.isNotEmpty) {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw ImageArtifactException(
          code: 'artifact_download_failed',
          message:
              'Image $index could not be downloaded from its (possibly '
              'expiring) URL — HTTP ${response.statusCode}',
        );
      }
      return GeneratedImage(
        filePath: await _write(response.bodyBytes, artifact.mimeType, index),
        mimeType: artifact.mimeType,
      );
    }
    throw ImageArtifactException(
      code: 'artifact_carrierless',
      message: 'Image $index carries no bytes, url or filePath',
    );
  }

  Future<String> _write(List<int> bytes, String mimeType, int index) async {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final extension = switch (mimeType) {
      'image/png' => 'png',
      'image/jpeg' => 'jpg',
      'image/webp' => 'webp',
      'image/gif' => 'gif',
      'image/svg+xml' => 'svg',
      _ => 'img',
    };
    await artifactsDirectory.create(recursive: true);
    final file = File(
      '${artifactsDirectory.path}/generated-$stamp-$index.$extension',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  void dispose() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}

/// A named materialization failure.
final class ImageArtifactException implements Exception {
  const ImageArtifactException({required this.code, required this.message});

  /// `artifact_download_failed` · `artifact_carrierless`.
  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

/// The note editor's composition of the images lane (native-image-assets
/// Wave D, LA ADR 0029): the OpenRouter images client under the SHARED
/// comparison budget (the same reserve/settle law the budget wire
/// keeps), materializing to the app-support `generated-images/` dir.
/// Null when no key is configured — the caller shows the honest
/// refusal instead of a dead button. Desktop-first: the key arrives
/// through the environment, exactly like the product-coding lane.
Future<ImageGenerationService?> composeForNotes() async {
  final key = Platform.environment['OPENROUTER_API_KEY'];
  if (key == null || key.isEmpty) return null;
  final support = await getApplicationSupportDirectory();
  return ImageGenerationService(
    client: ProductCloudImagesClient(
      apiKey: key,
      budget: ProductLocalPair.cloudBudget,
    ),
    artifactsDirectory: Directory('${support.path}/generated-images'),
  );
}
