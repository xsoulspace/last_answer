// ignore_for_file: lines_longer_than_80_chars

// A PURE-Dart test file (no flutter_test binding — its mocked
// HttpClient answers 400 and never touches a real socket). The binding
// read rung is REAL http: the daemon serves agent_doc_state, the source
// samples it, and a dead facade stays honest (null, never a throw).

import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';

void main() {
  test('sourceForBinding samples the daemon doc state over http', () async {
    final server = await HttpServer.bind('127.0.0.1', 0);
    addTearDown(server.close);
    server.listen((final request) async {
      final payload = jsonEncode({
        'ok': true,
        'docId': 'sess-test',
        'session': {
          'sessionId': 'sess-test',
          'running': false,
          'beats': [
            {'name': 'tool-beat', 'at': '2026-10-07T10:00:00Z'},
          ],
        },
      });
      request.response.headers.contentType = ContentType.json;
      request.response.write(payload);
      await request.response.close();
    });

    final binding = WorldBindingModel(
      worldId: 'harnessd-test',
      endpoint: 'http://127.0.0.1:${server.port}',
    );
    final trace = await sourceForBinding(binding).sample();
    expect(trace?.metrics['sessionId'], 'sess-test');
    expect(trace?.rows.length, 1);
  });

  test('a dead facade stays honest — null sample, never a throw', () async {
    final binding = WorldBindingModel(
      worldId: 'harnessd-gone',
      endpoint: 'http://127.0.0.1:1',
    );
    final trace = await sourceForBinding(binding).sample();
    expect(trace, isNull);
  });

  test('a bearer-gated facade gets the token as a header', () async {
    final server = await HttpServer.bind('127.0.0.1', 0);
    addTearDown(server.close);
    String? authorization;
    server.listen((final request) async {
      authorization = request.headers.value('authorization');
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'ok': true,
          'session': {'sessionId': 'sess-bearer'},
        }),
      );
      await request.response.close();
    });

    final binding = WorldBindingModel(
      worldId: 'harnessd-lan',
      endpoint: 'http://127.0.0.1:${server.port}',
    );
    final trace = await sourceForBinding(
      binding,
      token: 'secret-token',
    ).sample();
    expect(trace?.metrics['sessionId'], 'sess-bearer');
    expect(authorization, 'Bearer secret-token');
  });
}
