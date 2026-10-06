// CLI chat gate: the full attach-a-real-agent flow end to end, no UI.
//
//   choose provider (config defaults) → choose agent (catalog) →
//   install if needed (--install runs the catalog's declarative command) →
//   attach over ACP → auth guard (agents own their credentials; the gate
//   refuses with the named fix, it never automates login) → one real
//   prompt turn → assert a streamed reply.
//
// Usage:
//   fvm dart tool/gates/chat_cli_gate.dart
//       [--agent pi|gemini|codex|auto]  [--install] [--cwd <dir>]
//       [--prompt <text>]
// Exit codes: 0 pass · 1 failure · 2 auth required (user-gated).
// The equivalent UI path: Chat → transport picker → send (see
// lib/doc/chat_document_view.dart).
// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';

import 'package:lastanswer/agent_config/agent_platform_config.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';

/// `session/new`, answering an advertised ACP auth method first when
/// [authMethod] names one (e.g. `gemini-api-key`, resolved from the
/// agent's own env). Without it, an auth refusal surfaces as
/// [AcpAuthRequiredException] — the user-gated exit path.
Future<String> newSessionOrAuth(
  final AcpAgentRuntime runtime,
  final String cwd,
  final String authMethod,
) async {
  try {
    return await runtime.newSession(cwd).timeout(const Duration(seconds: 60));
  } on AcpAuthRequiredException catch (error) {
    if (authMethod.isEmpty) rethrow;
    final known = error.authMethods.any(
      (method) => method.methodId == authMethod,
    );
    print(
      'auth required — answering session/authenticate with "$authMethod" '
      '${known ? '' : '(not advertised; trying anyway)'}',
    );
    try {
      await runtime.authenticate(authMethod);
    } on AcpRemoteError catch (remote) {
      // Some agents advertise methods but do not implement
      // session/authenticate (gemini-cli among them) — their auth is
      // env/terminal only. Fall through to the user-gated exit.
      print(
        'agent refused session/authenticate: ${remote.message} — '
        'falling back to its own login flow',
      );
      rethrow;
    }
    return runtime.newSession(cwd).timeout(const Duration(seconds: 60));
  }
}

const _reset = '\x1B[0m';
const _green = '\x1B[32m';
const _red = '\x1B[31m';
const _yellow = '\x1B[33m';

void stage(final int number, final String name) =>
    print('\n=== stage $number · $name ===');

void pass(final String message) => print('$_green✓$_reset $message');

void fail(final String message, {final String? fix}) {
  print('$_red✗ $message$_reset');
  if (fix != null) print('  fix: $fix');
}

String _arg(final List<String> args, final String name) {
  final index = args.indexOf('--$name');
  if (index < 0 || index + 1 >= args.length) return '';
  return args[index + 1];
}

Future<void> main(final List<String> args) async {
  final wanted = _arg(args, 'agent').isEmpty ? 'auto' : _arg(args, 'agent');
  final cwd = _arg(args, 'cwd').isEmpty
      ? Directory.current.path
      : _arg(args, 'cwd');
  final prompt = _arg(args, 'prompt').isEmpty
      ? 'Reply with exactly: GATE-OK'
      : _arg(args, 'prompt');
  final doInstall = args.contains('--install');
  final authMethod = _arg(args, 'auth-method');

  // ------------------------------------------------------------------
  stage(1, 'config · providers');
  final config = AgentPlatformConfig.defaults();
  final provider = config.providers[AgentPlatformConfig.openRouterId];
  final envKey = (provider?.apiKeyEnv ?? '').isEmpty
      ? null
      : Platform.environment[provider!.apiKeyEnv];
  pass(
    'agent_config.json defaults: ${config.providers.keys.join(', ')}; '
    'hosted key via ${provider?.apiKeyEnv ?? '-'}: '
    '${envKey == null ? 'not set (hosted chat lane untested here)' : 'set'}',
  );

  // ------------------------------------------------------------------
  stage(2, 'agent · detect (install if needed)');
  final service = AcpInstallationService();
  const catalog = AcpAgentCatalog.defaultEntries;
  var installations = await service.detectAll();
  AcpAgentInstallation? selected;
  if (wanted == 'auto') {
    selected = installations.firstOrNull;
  } else {
    selected = installations
        .where((install) => install.entry.id == wanted)
        .firstOrNull;
  }
  if (selected == null) {
    final entry = wanted == 'auto'
        ? catalog.first
        : catalog.where((e) => e.id == wanted).firstOrNull;
    final command = entry?.installCommand;
    if (entry == null) {
      fail(
        'agent "$wanted" is not in the catalog',
        fix: 'catalog entries: ${catalog.map((e) => e.id).join(', ')}; '
            'or register a server in agent_config.json',
      );
      exit(1);
    }
    if (!doInstall || command == null) {
      fail(
        '${entry.displayName} not found on PATH',
        fix: 're-run with --install to run: ${command?.join(' ')}',
      );
      exit(1);
    }
    print('${_yellow}installing: ${command.join(' ')}$_reset');
    final install = await Process.run(
      command.first,
      command.sublist(1),
    );
    if (install.exitCode != 0) {
      fail(
        'install failed (${install.exitCode})',
        fix: 'check the installer output above',
      );
      exit(1);
    }
    installations = await service.detectAll();
    selected = installations
        .where((install) => install.entry.id == entry.id)
        .firstOrNull;
    if (selected == null) {
      fail(
        '${entry.displayName} still not detected after install',
        fix: 'check PATH and the installer output',
      );
      exit(1);
    }
    pass('installed and detected: ${selected.path}');
  } else {
    pass('detected ${selected.entry.displayName} at ${selected.path}');
  }

  // ------------------------------------------------------------------
  stage(3, 'attach · ACP handshake');
  final runtime = AcpAgentRuntime();
  final agentStderr = <String>[];
  var sessionId = '';
  try {
    // The handshake must not hang forever: a quiet agent (e.g. waiting
    // for interactive auth it never announced) fails the gate with a
    // named timeout instead of blocking CI.
    await runtime
        .start(
          AcpRuntimeConfig.fromInstallation(selected, workingDirectory: cwd),
          onStderr: (final line) {
            agentStderr.add(line);
            if (agentStderr.length > 40) agentStderr.removeAt(0);
          },
        )
        .timeout(const Duration(seconds: 60));
    sessionId = await newSessionOrAuth(runtime, cwd, authMethod);
    pass('session ready: $sessionId');
  } on TimeoutException {
    fail(
      'attach timed out after 60s (no ACP handshake)',
      fix:
          'run `${selected.entry.commandCandidates.first}` in a terminal — '
          'it may be waiting for interactive first-run output '
          '(${selected.entry.installHint ?? 'check the CLI docs'})',
    );
    await runtime.stop();
    exit(1);
  } on AcpAuthRequiredException catch (error) {
    // Auth is the agent's own credential store — the gate NEVER automates
    // login (Zed parity): it names the fix and hands the exit to the user.
    final hint = selected.entry.authHint ?? error.message;
    fail(
      '${selected.entry.displayName} requires authentication',
      fix: hint,
    );
    if (error.authMethods.isNotEmpty) {
      print(
        '  ACP auth methods: '
        '${error.authMethods.map((m) => m.methodId).join(', ')}',
      );
    }
    await runtime.stop();
    exit(2);
  } on Object catch (error) {
    fail(
      'ACP handshake failed: $error',
      fix: 'run the agent CLI once in a terminal to see its own error',
    );
    await runtime.stop();
    exit(1);
  }

  // ------------------------------------------------------------------
  stage(4, 'turn · one real prompt');
  final text = StringBuffer();
  var toolCalls = 0;
  final done = Completer<void>();
  Object? turnError;
  late final StreamSubscription<AcpPromptUpdate> subscription;
  void finish() {
    if (!done.isCompleted) done.complete();
  }

  subscription = runtime.send(prompt, sessionId: sessionId).listen(
    (update) {
      if (update.textDelta != null) {
        text.write(update.textDelta);
      } else if (update.message != null) {
        toolCalls++;
      }
    },
    onDone: finish,
    onError: (final Object error) {
      turnError = error;
      finish();
    },
  );
  await done.future.timeout(
    const Duration(minutes: 5),
    onTimeout: () {
      turnError = 'turn timed out after 5 minutes';
      unawaited(subscription.cancel());
      runtime.cancel(sessionId);
      finish();
    },
  );
  final reply = text.toString().trim();
  if (turnError != null) {
    fail('turn errored: $turnError');
    if (agentStderr.isNotEmpty) {
      print('  agent stderr (last lines):');
      for (final line in agentStderr.take(5)) {
        print('    ${line.length > 160 ? '${line.substring(0, 160)}…' : line}');
      }
    }
    await runtime.stop();
    exit(1);
  }
  if (reply.isEmpty) {
    fail(
      'empty reply (tool calls observed: $toolCalls)',
      fix: 'check the agent CLI output for its own error',
    );
    await runtime.stop();
    exit(1);
  }
  pass(
    'reply (${reply.length} chars, $toolCalls tool-call titles): '
    '${reply.length > 120 ? '${reply.substring(0, 120)}…' : reply}',
  );

  // ------------------------------------------------------------------
  stage(5, 'cleanup');
  await runtime.stop();
  pass('runtime stopped cleanly');
  print('\n$_green GATE PASS — real agent attached and answered.$_reset');
}
