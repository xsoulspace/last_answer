import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lastanswer/browser/browser_entry.dart';
import 'package:lastanswer/coding_agent/project_operations/project_operations.dart'
    show ProjectOperationKind;
import 'package:lastanswer/coding_agent/project_operations/project_operations_session.dart';

/// The declared project operations of a workspace, as an ordinary surface.
///
/// The panel shows what the *project* declared and runs an operation only
/// when a person clicks. The check operation is labelled "Working tree
/// check": it runs the project's own command against the owner project
/// root, so it is never a candidate verification and never an acceptance.
///
/// The served target belongs to oka's browser session. The panel opens the
/// general browser at the URL that session exposes and stops only a process
/// the session owns.
final class ProjectOperationsWidget extends StatefulWidget {
  /// Creates the panel over [session].
  const ProjectOperationsWidget({
    required this.session,
    this.openBrowser,
    super.key,
  });

  /// The session that owns the declaration and the runs.
  final ProjectOperationsSession session;

  /// Opens the browser at a served target.
  ///
  /// The application reuses its own browser window when this is null; a
  /// surface that owns another browser passes it in.
  final Future<void> Function(BuildContext context, Uri url)? openBrowser;

  @override
  State<ProjectOperationsWidget> createState() =>
      _ProjectOperationsWidgetState();
}

final class _ProjectOperationsWidgetState
    extends State<ProjectOperationsWidget> {
  @override
  void initState() {
    super.initState();
    // Reading the declaration starts nothing: no command runs until a
    // person clicks.
    unawaited(widget.session.load());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.session,
    builder: (context, _) {
      final session = widget.session;
      final theme = Theme.of(context);
      final mono = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
      final text = _OpsText(Localizations.localeOf(context).languageCode);
      final endpoint = session.endpoint;
      final ownership = session.ownership?.name ?? 'unknown';
      final retained = session.retainedLastKnownGood
          ? ' · ${text.retained}'
          : '';
      return Semantics(
        identifier: 'project_operations',
        container: true,
        explicitChildNodes: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            key: const Key('project_operations.widget'),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(text.title, style: theme.textTheme.titleSmall),
                  ),
                  TextButton(
                    key: const Key('project_operations.reload'),
                    onPressed: session.closing || session.closed
                        ? null
                        : session.load,
                    child: Text(text.reload),
                  ),
                ],
              ),
              if (session.loadState == ProjectOperationsLoadState.absent)
                Text(
                  text.absent,
                  key: const Key('project_operations.absent'),
                  style: theme.textTheme.bodySmall,
                ),
              if (session.loadState == ProjectOperationsLoadState.invalid) ...[
                Text(
                  session.declarationError ?? text.invalid,
                  key: const Key('project_operations.error'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                if (session.declarationDetail != null)
                  Text(
                    session.declarationDetail!,
                    key: const Key('project_operations.error.detail'),
                    style: mono,
                  ),
              ],
              if (session.profile != null) ...[
                Text(
                  '${session.profile!.id} · ${text.declared}',
                  key: const Key('project_operations.declaration'),
                  style: mono,
                ),
                for (final operation in session.profile!.operations)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${operation.kind.name} · ${operation.id}',
                          style: theme.textTheme.labelSmall,
                        ),
                        // The declared argv, never the environment values.
                        Text(
                          operation.command.argv.join(' '),
                          key: Key(
                            'project_operations.operation.${operation.id}',
                          ),
                          style: mono,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      key: const Key('project_operations.check'),
                      onPressed:
                          !session.canStartOperation ||
                              !session.supports(ProjectOperationKind.check)
                          ? null
                          : session.runCheck,
                      child: Text(text.workingTreeCheck),
                    ),
                    TextButton(
                      key: const Key('project_operations.build'),
                      onPressed:
                          !session.canStartOperation ||
                              !session.supports(ProjectOperationKind.build)
                          ? null
                          : session.runBuild,
                      child: Text(text.build),
                    ),
                    TextButton(
                      key: const Key('project_operations.serve'),
                      onPressed:
                          !session.canStartOperation ||
                              !session.supports(ProjectOperationKind.serve)
                          ? null
                          : () => _serveAndOpen(context),
                      child: Text(text.serve),
                    ),
                    TextButton(
                      key: const Key('project_operations.stop'),
                      onPressed:
                          session.busy || session.closing || !session.hasTarget
                          ? null
                          : session.stop,
                      child: Text(text.stop),
                    ),
                    TextButton(
                      key: const Key('project_operations.cancel'),
                      onPressed: session.busy ? session.cancel : null,
                      child: Text(text.cancel),
                    ),
                  ],
                ),
                Text(
                  text.workingTreeNote,
                  key: const Key('project_operations.working_tree_note'),
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  _status(session, text),
                  key: const Key('project_operations.status'),
                  style: mono,
                ),
                if (endpoint != null)
                  Text(
                    '$endpoint · $ownership$retained',
                    key: const Key('project_operations.endpoint'),
                    style: mono,
                  ),
                if (session.logs.isNotEmpty)
                  SelectableText(
                    session.logs,
                    key: const Key('project_operations.logs'),
                    style: mono,
                    maxLines: 12,
                  ),
              ],
              if (session.errorDetail != null)
                SelectableText(
                  session.errorDetail!,
                  key: const Key('project_operations.failure_detail'),
                  style: mono,
                ),
            ],
          ),
        ),
      );
    },
  );

  Future<void> _serveAndOpen(BuildContext context) async {
    final session = widget.session;
    await session.serve();
    final url = session.endpoint;
    if (!context.mounted ||
        session.closing ||
        session.closed ||
        session.runState != ProjectOperationsRunState.completed ||
        url == null) {
      return;
    }
    final open = widget.openBrowser ?? _openWorkspaceBrowser;
    await open(context, url);
  }
}

Future<void> _openWorkspaceBrowser(BuildContext context, Uri url) =>
    openWorkspaceBrowser(context, initialUrl: url);

String _status(ProjectOperationsSession session, _OpsText text) {
  switch (session.runState) {
    case ProjectOperationsRunState.idle:
      return text.idle;
    case ProjectOperationsRunState.running:
      return text.running;
    case ProjectOperationsRunState.cancelled:
      return text.cancelled;
    case ProjectOperationsRunState.completed:
    case ProjectOperationsRunState.failed:
      final outcome = session.outcome;
      final serve = session.serveOutcome;
      final error = session.error;
      if (outcome != null) {
        return '${text.finished} · '
            '${outcome.ok && error == null ? text.ok : text.failed}'
            '${outcome.exitCode == null ? '' : ' · exit ${outcome.exitCode}'}'
            '${error == null ? '' : ' · $error'}';
      }
      if (serve != null) {
        return '${text.finished} · '
            '${serve.ok && error == null ? text.ok : text.failed}'
            '${error == null ? '' : ' · $error'}';
      }
      return error == null ? text.finished : '${text.failed} · $error';
  }
}

/// The panel's own words, in the app's three languages.
final class _OpsText {
  const _OpsText(this.locale);
  final String locale;
  String choose(String en, String it, String ru) => switch (locale) {
    'it' => it,
    'ru' => ru,
    _ => en,
  };
  String get title => choose(
    'Project operations',
    'Operazioni del progetto',
    'Операции проекта',
  );
  String get reload => choose('Reload', 'Ricarica', 'Обновить');
  String get declared => choose(
    'declared by the project',
    'dichiarate dal progetto',
    'объявлены проектом',
  );
  String get absent => choose(
    'This project declares no operations. Add .oka/project_operations.json at '
        'the project root.',
    'Questo progetto non dichiara operazioni. Aggiungi '
        '.oka/project_operations.json nella radice del progetto.',
    'Проект не объявляет операций. Добавьте .oka/project_operations.json в '
        'корень проекта.',
  );
  String get invalid => choose(
    'The declaration was refused',
    'La dichiarazione è stata rifiutata',
    'Объявление отклонено',
  );
  String get workingTreeCheck => choose(
    'Working tree check',
    'Verifica dell’albero di lavoro',
    'Проверка рабочего дерева',
  );
  String get build => choose('Build', 'Compila', 'Сборка');
  String get serve =>
      choose('Serve & open', 'Servi e apri', 'Запусти и открой');
  String get stop => choose('Stop', 'Ferma', 'Остановить');
  String get cancel => choose('Cancel', 'Annulla', 'Отмена');
  String get workingTreeNote => choose(
    'The check runs the project’s own command on the working tree. It is not '
        'a candidate verification and not an acceptance.',
    'La verifica esegue il comando del progetto sull’albero di lavoro. Non è '
        'una verifica del candidato né un’accettazione.',
    'Проверка выполняет собственную команду проекта в рабочем дереве. Это не '
        'проверка кандидата и не приёмка.',
  );
  String get idle => choose('Idle', 'Inattivo', 'Ожидание');
  String get running => choose('Running…', 'In esecuzione…', 'Выполняется…');
  String get cancelled => choose(
    'Cancelled — the command was stopped',
    'Annullato — il comando è stato fermato',
    'Отменено — команда остановлена',
  );
  String get finished => choose('Finished', 'Concluso', 'Завершено');
  String get ok => choose('ok', 'ok', 'ок');
  String get failed => choose('failed', 'non superata', 'не пройдено');
  String get retained => choose(
    'last known good target retained',
    'ultimo target valido mantenuto',
    'сохранена последняя рабочая цель',
  );
}
