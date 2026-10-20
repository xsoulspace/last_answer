import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';
import 'package:lastanswer/coding_agent/meaning_experiment_view.dart';
import 'package:lastanswer/coding_agent/product_workspace_tooling.dart';

/// A visual projection of native candidate evidence. Live Apply completes the
/// existing exact pending permission; it never invokes another authoring actor.
final class ProductCodingChangeView extends StatelessWidget {
  const ProductCodingChangeView({
    required this.binding,
    this.controller,
    this.onAction,
    this.busy = false,
    super.key,
  });

  final ProductWorkspaceToolBinding binding;
  final HarnessSessionController? controller;
  final Future<Map<String, Object?>> Function(String, Map<String, Object?>)?
  onAction;
  final bool busy;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([binding.observation, ?controller]),
    builder: (context, _) {
      final observation = binding.observation.value;
      if (observation == null) {
        return onAction == null
            ? const SizedBox.shrink()
            : TextButton(
                key: const Key('coding_agent.change.refresh'),
                onPressed: busy ? null : () => onAction!('status', const {}),
                child: Text(
                  _CodeText(Localizations.localeOf(context).languageCode).saved,
                ),
              );
      }
      final result = observation['result']! as Map;
      Map<String, Object?>? preview = binding.previewObservation;
      final pending = controller?.pendingPermission;
      if (pending != null && !pending.isAnswered) {
        try {
          final exact = jsonDecode(pending.request.details ?? '') as Map;
          preview = binding.reviewFor(exact);
        } on Object {
          preview = null;
        }
      }
      final candidate = preview?['result'] as Map?;
      final proposal = candidate?['proposal'] as Map?;
      final footprint = candidate?['footprint'] as Map? ?? const {};
      final diff = proposal?['diff'] as String? ?? '';
      final text = _CodeText(Localizations.localeOf(context).languageCode);
      final ready = _matchesPending(controller, proposal);
      void answer({required bool allow}) {
        if (_matchesPending(controller, proposal)) {
          controller!.answerPermission(allow: allow);
        }
      }

      final theme = Theme.of(context);
      final mono = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
      return Semantics(
        identifier: 'coding_agent.change',
        container: true,
        explicitChildNodes: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 52, child: Text('SYS', style: mono)),
              Expanded(
                child: Column(
                  key: const Key('coding_agent.change'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).agentCodeChange,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${observation['taskId']} · ${observation['action']} · '
                      '${result['native_status'] ?? result['error'] ?? ''}',
                      key: const Key('coding_agent.change.origin'),
                      style: mono,
                    ),
                    if (result['ok'] != true)
                      SelectableText(
                        '${result['error'] ?? result['check'] ?? ''}',
                        key: const Key('coding_agent.change.refusal'),
                      ),
                    // Autonomous work presents the running product. Exact code
                    // Receipts remain under the existing details fold.
                    if (candidate != null &&
                        binding.standingAuthority == null) ...[
                      Text(text.scope, style: theme.textTheme.labelSmall),
                      for (final entry in footprint.entries)
                        Text(
                          '${entry.value}  ${entry.key}',
                          style: mono,
                          key: ValueKey(
                            'coding_agent.change.footprint.${entry.key}',
                          ),
                        ),
                      Text(
                        candidate['files'] is Map ? text.sources : text.regions,
                        style: theme.textTheme.bodySmall,
                      ),
                      for (final file
                          in _sourceFiles(candidate) ?? _changedRegions(diff))
                        _FileRegions(file: file, text: text),
                      if (candidate['check'] case final check?) ...[
                        Text(text.check, style: theme.textTheme.labelSmall),
                        SelectableText(
                          _checkSummary(check, text),
                          key: const Key('coding_agent.change.check'),
                          style: mono,
                        ),
                      ],
                      Text(text.limit, style: theme.textTheme.bodySmall),
                      if (ready)
                        Wrap(
                          children: [
                            TextButton(
                              key: const Key('coding_agent.change.reject'),
                              onPressed: () => answer(allow: false),
                              child: Text(text.reject),
                            ),
                            TextButton(
                              key: const Key('coding_agent.change.apply'),
                              onPressed: () => answer(allow: true),
                              child: Text(text.apply),
                            ),
                          ],
                        ),
                    ],
                    if (onAction != null) ...[
                      TextButton(
                        key: const Key('coding_agent.change.refresh'),
                        onPressed: busy
                            ? null
                            : () => onAction!('status', const {}),
                        child: Text(text.saved),
                      ),
                      for (final saved in binding.savedCandidates)
                        ExpansionTile(
                          key: ValueKey(
                            'coding_agent.change.saved.${saved['candidateId']}',
                          ),
                          title: Text('${saved['originTaskId']}'),
                          children: [
                            for (final file
                                in _sourceFiles(saved) ?? <_Regions>[])
                              _FileRegions(file: file, text: text),
                            TextButton(
                              onPressed: busy || ready
                                  ? null
                                  : () => onAction!('reviewSaved', {
                                      'candidateId': saved['candidateId'],
                                    }),
                              child: Text(text.reviewSaved),
                            ),
                          ],
                        ),
                    ],
                    if (onAction != null && !ready)
                      Wrap(
                        children: [
                          if (candidate?['candidateId'] case final String id)
                            TextButton(
                              key: const Key('coding_agent.change.reviewSaved'),
                              onPressed: busy || controller?.isRunning == true
                                  ? null
                                  : () => onAction!('reviewSaved', {
                                      'candidateId': id,
                                    }),
                              child: Text(text.reviewSaved),
                            ),
                          if (binding.undoRunId case final id?)
                            TextButton(
                              key: const Key('coding_agent.change.undo'),
                              onPressed: busy || controller?.isRunning == true
                                  ? null
                                  : () => onAction!('recoverRollback', {
                                      'runId': id,
                                    }),
                              child: Text(text.undo),
                            ),
                        ],
                      ),
                    MeaningEvidenceDetails(
                      key: const Key('coding_agent.change.receipt'),
                      title: text.details,
                      body: const JsonEncoder.withIndent(
                        '  ',
                      ).convert(observation),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  static bool _matchesPending(
    HarnessSessionController? controller,
    Map? proposal,
  ) {
    final pending = controller?.pendingPermission;
    if (pending == null ||
        pending.isAnswered ||
        proposal == null ||
        controller?.current?.id != pending.request.sessionId) {
      return false;
    }
    try {
      final exact = jsonDecode(pending.request.details ?? '') as Map;
      return exact['proposalId'] == proposal['proposalId'] &&
          exact['effectDigest'] == proposal['effectDigest'] &&
          exact['taskId'] == proposal['taskId'] &&
          exact['proposalId'] != null &&
          exact['effectDigest'] != null;
    } on Object {
      return false;
    }
  }
}

String _checkSummary(Object check, _CodeText text) {
  if (check is Map) {
    final parts = <String>[];
    if (check['grade'] == 'compiler_only') parts.add(text.compilerOnly);
    if (check['checks'] case final List checks) {
      for (final item in checks.whereType<Map>()) {
        parts.add(
          '${item['entrypoint'] ?? ''}: '
          '${item['exitCode'] == 0 ? text.passed : text.failed}',
        );
        for (final key in ['stdout', 'stderr', 'refusal']) {
          final value = item[key];
          if (value != null && '$value'.trim().isNotEmpty) {
            parts.add('$value');
          }
        }
      }
    }
    for (final name in ['exitCode', 'stdout', 'stderr', 'error']) {
      final value = check[name];
      if (value != null && '$value'.trim().isNotEmpty) {
        parts.add('$name: $value');
      }
    }
    if (parts.isNotEmpty) return parts.join('\n');
  }
  return const JsonEncoder.withIndent('  ').convert(check);
}

final class _Regions {
  _Regions(this.path);
  final String path;
  final before = <String>[];
  final after = <String>[];
  bool beforeAbsent = false;
  bool afterAbsent = false;
}

List<_Regions>? _sourceFiles(Map? candidate) {
  final files = candidate?['files'];
  if (files is! Map) return null;
  return [
    for (final entry in files.entries)
      if (entry.key is String && entry.value is Map)
        _Regions(entry.key as String)
          ..beforeAbsent = (entry.value as Map)['before'] == null
          ..afterAbsent = (entry.value as Map)['after'] == null
          ..before.addAll(
            ((entry.value as Map)['before'] as String? ?? '').split('\n'),
          )
          ..after.addAll(
            ((entry.value as Map)['after'] as String? ?? '').split('\n'),
          ),
  ];
}

/// These are exact changed regions from the acknowledged native diff, not a
/// reconstruction of full file contents or a fresh read of authoritative files.
List<_Regions> _changedRegions(String diff) {
  final files = <_Regions>[];
  _Regions? current;
  var inHunk = false;
  for (final line in diff.split('\n')) {
    if (line.startsWith('--- ')) {
      final raw = line.substring(4);
      current = _Regions(raw.startsWith('a/') ? raw.substring(2) : raw);
      files.add(current);
      inHunk = false;
    } else if (line.startsWith('+++ ')) {
      if (current?.path == '/dev/null') {
        final raw = line.substring(4);
        current = _Regions(raw.startsWith('b/') ? raw.substring(2) : raw);
        files[files.length - 1] = current;
      }
      inHunk = false;
    } else if (line.startsWith('@@')) {
      inHunk = true;
      current?.before.add(line);
      current?.after.add(line);
    } else if (inHunk && current != null && line.isNotEmpty) {
      if (line.startsWith('-')) {
        current.before.add(line.substring(1));
      } else if (line.startsWith('+')) {
        current.after.add(line.substring(1));
      } else if (line.startsWith(' ')) {
        current.before.add(line.substring(1));
        current.after.add(line.substring(1));
      }
    }
  }
  return files;
}

class _FileRegions extends StatelessWidget {
  const _FileRegions({required this.file, required this.text});
  final _Regions file;
  final _CodeText text;

  @override
  Widget build(BuildContext context) {
    final mono = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    Widget side(
      String label,
      List<String> lines,
      String suffix, {
      required bool absent,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            absent ? text.absent : lines.join('\n'),
            style: mono,
            key: ValueKey('coding_agent.change.file.${file.path}.$suffix'),
          ),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(file.path, style: mono),
          LayoutBuilder(
            builder: (context, size) {
              final before = side(
                text.before,
                file.before,
                'before',
                absent: file.beforeAbsent,
              );
              final after = side(
                text.after,
                file.after,
                'after',
                absent: file.afterAbsent,
              );
              if (size.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [before, const SizedBox(height: 8), after],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: before),
                  const SizedBox(width: 16),
                  Expanded(child: after),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

final class _CodeText {
  const _CodeText(this.locale);
  final String locale;
  String choose(String en, String it, String ru) => switch (locale) {
    'it' => it,
    'ru' => ru,
    _ => en,
  };
  String get scope =>
      choose('Changed files', 'File modificati', 'Изменённые файлы');
  String get regions => choose(
    'Changed regions from the verified candidate',
    'Parti modificate della proposta verificata',
    'Изменённые области проверенного кандидата',
  );
  String get sources => choose(
    'Original and candidate source',
    'Sorgente originale e proposto',
    'Исходный и предлагаемый код',
  );
  String get compilerOnly => choose(
    'Compiler check only; program not run',
    'Solo verifica del compilatore; programma non eseguito',
    'Только проверка компилятором; программа не запускалась',
  );
  String get passed => choose('Passed', 'Superata', 'Пройдена');
  String get failed => choose('Failed', 'Non superata', 'Не пройдена');
  String get absent =>
      choose('File absent', 'File assente', 'Файл отсутствует');
  String get before => choose('Before', 'Prima', 'До');
  String get after => choose('After', 'Dopo', 'После');
  String get check =>
      choose('Check output', 'Risultato della verifica', 'Результат проверки');
  String get limit => choose(
    'Candidate checks are evidence; task acceptance is separate.',
    'Le verifiche sono evidenza; l’accettazione dell’attività è separata.',
    'Проверки дают свидетельства; приёмка задачи выполняется отдельно.',
  );
  String get reject => choose('Reject', 'Rifiuta', 'Отклонить');
  String get apply => choose('Apply', 'Applica', 'Применить');
  String get saved =>
      choose('Saved changes', 'Modifiche salvate', 'Сохранённые изменения');
  String get reviewSaved => choose(
    'Review for Apply',
    'Rivedi per applicare',
    'Проверить перед применением',
  );
  String get undo => choose('Undo', 'Annulla', 'Отменить');
  String get details =>
      choose('Native receipt', 'Riscontro nativo', 'Нативная квитанция');
}
