import 'dart:async';

import 'dart:convert';

import 'package:dio/dio.dart';

/// A minimal JSON-RPC-over-HTTP client for the resident universal
/// automation serve (ADR 0010 phase 3): the ≈4 methods the lens surface
/// needs — initialize, automation_act, automation_observe,
/// automation_presence. Deliberately NOT an MCP client library: no
/// resources, prompts, subscriptions, or transports beyond the one
/// Streamable-HTTP POST loop this host uses.
final class AutomationMcpClient {
  AutomationMcpClient({required this.endpoint, this.agentId = 'lastanswer'})
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json, text/event-stream'},
        ),
      );

  /// The resident serve's Streamable-HTTP endpoint
  /// (configs/automation.json: http://127.0.0.1:8192/mcp).
  final Uri endpoint;

  /// The event-plane identity this host acts under (ADR 0010): every
  /// act/observe names it, so other agents see who moved.
  final String agentId;

  final Dio _dio;
  int _nextId = 0;
  bool _initialized = false;
  String? _sessionId;

  Future<Map<String, Object?>> _call(
    String method, [
    Map<String, Object?>? params,
  ]) async {
    final id = ++_nextId;
    final response = await _dio.post<Map<String, Object?>>(
      endpoint.toString(),
      options: Options(
        headers: {
          'Mcp-Session-Id': ?_sessionId,
        },
        responseType: ResponseType.json,
      ),
      data: {
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        'params': ?params,
      },
    );
    final session = response.headers.value('mcp-session-id');
    if (session != null) _sessionId = session;
    final body = response.data;
    if (body == null) throw StateError('empty response from $endpoint');
    final error = body['error'];
    if (error is Map) {
      throw AutomationMcpException(
        '${error['message'] ?? error}',
        details: error is Map<String, Object?> ? error : null,
      );
    }
    final result = body['result'];
    if (result is! Map<String, Object?>) {
      throw StateError('malformed result from $endpoint: $body');
    }
    return result;
  }

  /// Unwraps a tools/call text content block into its JSON payload.
  Future<Map<String, Object?>> _toolCall(
    String name,
    Map<String, Object?> arguments,
  ) async {
    final result = await _call('tools/call', {
      'name': name,
      'arguments': arguments,
    });
    if (result['isError'] == true) {
      final content = result['content'];
      final text = content is List && content.isNotEmpty
          ? '${(content.first as Map)['text']}'
          : 'tool error';
      throw AutomationMcpException(text);
    }
    final content = result['content'];
    if (content is! List || content.isEmpty) return const {};
    final first = content.first;
    if (first is! Map) return const {};
    final text = first['text'];
    if (text is! String) return const {};
    // The toolkit serializes payloads as JSON text blocks.
    final decoded = jsonDecode(text);
    return decoded is Map<String, Object?> ? decoded : {'text': text};
  }

  /// Ensures the initialize handshake happened once per client.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _call('initialize', {
      'protocolVersion': '2025-03-26',
      'capabilities': {},
      'clientInfo': {'name': 'lastanswer-lens', 'version': '0.1.0'},
    });
    _initialized = true;
    // notifications/initialized — fire and forget.
    unawaited(
      _dio
          .post(
            endpoint.toString(),
            options: Options(
              headers: {
                'Mcp-Session-Id': ?_sessionId,
              },
            ),
            data: const {
              'jsonrpc': '2.0',
              'method': 'notifications/initialized',
            },
          )
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  /// One act on the serve's tier. [arguments] are the automation_act
  /// arguments verbatim (action, url, role, name, x, y, …); the host's
  /// agentId rides along automatically.
  Future<Map<String, Object?>> act(Map<String, Object?> arguments) async {
    await ensureInitialized();
    return _toolCall('automation_act', {...arguments, 'agentId': agentId});
  }

  /// One semantic observation.
  Future<Map<String, Object?>> observe([
    Map<String, Object?>? arguments,
  ]) async {
    await ensureInitialized();
    return _toolCall('automation_observe', {
      ...?arguments,
      'agentId': agentId,
    });
  }

  /// The presence poll — the lens overlay's feed (ADR 0010 event plane).
  Future<Map<String, Object?>> presence([String? forAgent]) async {
    await ensureInitialized();
    return _toolCall('automation_presence', {
      'agentId': ?forAgent,
    });
  }

  /// Drops the session (client-side only — the serve keeps running).
  void close() => _dio.close();
}

/// A tool-level failure surfaced as a typed exception (the toolkit
/// answers automation failures as isError results, not transport errors).
final class AutomationMcpException implements Exception {
  AutomationMcpException(this.message, {this.details});
  final String message;
  final Map<String, Object?>? details;

  @override
  String toString() => 'AutomationMcpException: $message';
}
