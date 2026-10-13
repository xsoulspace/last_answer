import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:lastanswer/coding_agent/meaning_experiment_controller.dart';

/// The document's reversible change flow. Diagnostic receipts remain available
/// through disclosure; the view never creates native execution authority.
final class MeaningExperimentView extends StatelessWidget {
  const MeaningExperimentView({
    required this.controller,
    this.onAction,
    this.admissionBusy = false,
    super.key,
  });
  final MeaningExperimentController controller;
  final bool admissionBusy;
  final Future<Map<String, Object?>> Function(String action)? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = _MeaningText(Localizations.localeOf(context).languageCode);
    final mono = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    Future<Map<String, Object?>> act(String action) =>
        (onAction ?? controller.action)(action);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final busy = controller.busy || admissionBusy;
        final preview = controller.preview;
        final stage = (preview?['evidence'] as Map?)?['stage'] ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 52, child: Text('SYS', style: mono)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text.title,
                      key: const Key('coding_agent.meaning.title'),
                    ),
                    if (preview == null) Text(text.instruction),
                    if (controller.currentObservationUnknown)
                      Text(
                        text.unknown,
                        key: const Key(
                          'coding_agent.meaning.current_observation_unknown',
                        ),
                      ),
                    if (controller.currentObservation != null) ...[
                      Text(text.current),
                      SelectableText(
                        text.observation(controller.currentObservation),
                        key: const Key(
                          'coding_agent.meaning.current_observation',
                        ),
                      ),
                    ],
                    if (preview != null && !controller.proposalInvoked)
                      SelectableText(
                        '${text.before}\n'
                        '${text.observation(preview['baseline_observation'])}'
                        '\n\n${text.after}\n'
                        '${text.observation(preview['candidate_observation'])}',
                        key: const Key('coding_agent.meaning.observations'),
                      ),
                    Wrap(
                      spacing: 12,
                      children: [
                        TextButton(
                          key: const Key('coding_agent.meaning.preview'),
                          onPressed: busy || controller.rollbackAvailable
                              ? null
                              : () => act('preview'),
                          child: Text(
                            controller.proposalInvoked
                                ? text.previewAgain
                                : text.preview,
                          ),
                        ),
                        if (!controller.rollbackAvailable)
                          TextButton(
                            key: const Key('coding_agent.meaning.apply'),
                            onPressed:
                                busy ||
                                    controller.proposalId == null ||
                                    controller.proposalInvoked
                                ? null
                                : () => act('apply'),
                            child: Text(text.apply),
                          ),
                        if (controller.rollbackAvailable)
                          TextButton(
                            // Keep the established native/key contract; Undo is
                            // the user's label for the same rollback operation.
                            key: const Key('coding_agent.meaning.rollback'),
                            onPressed: busy ? null : () => act('rollback'),
                            child: Text(text.undo),
                          ),
                      ],
                    ),
                    if (busy)
                      Text(
                        text.working,
                        key: const Key('coding_agent.meaning.busy'),
                      ),
                    if (controller.refusal != null)
                      Text(
                        text.refusal(controller.refusal!),
                        key: const Key('coding_agent.meaning.refusal'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    MeaningEvidenceDetails(
                      surfaceKey: const Key('coding_agent.meaning.details'),
                      title: text.details,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (preview != null) ...[
                            SelectableText(
                              '${(preview['proposal'] as Map?)?['diff'] ?? ''}',
                              key: const Key('coding_agent.meaning.diff'),
                              style: mono,
                            ),
                            Text(
                              '${controller.proposalId} · '
                              '$stage · '
                              '${preview['elapsed_us']} µs',
                              key: const Key(
                                'coding_agent.meaning.preview_status',
                              ),
                              style: mono,
                            ),
                          ],
                          TextButton(
                            key: const Key('coding_agent.meaning.status'),
                            onPressed: busy ? null : () => act('status'),
                            child: Text(text.status),
                          ),
                          TextButton(
                            key: const Key('coding_agent.meaning.finalize'),
                            onPressed: busy || !controller.rollbackAvailable
                                ? null
                                : () => act('finalize'),
                            child: Text(text.finalize),
                          ),
                          if (controller.refusal != null)
                            SelectableText(controller.refusal!, style: mono),
                          for (final (index, receipt)
                              in controller.receipts.indexed)
                            MeaningEvidenceDetails(
                              key: Key('coding_agent.meaning.receipt.$index'),
                              title: _receiptTitle(receipt),
                              body: const JsonEncoder.withIndent(
                                '  ',
                              ).convert(receipt),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _receiptTitle(Map<String, Object?> receipt) {
    final action = receipt['action'] ?? 'preview';
    final id = receipt['runId'] ?? controller.proposalId ?? '';
    final outcome = receipt['ok'] == true ? 'ok' : receipt['error'];
    return '$action · $id · $outcome · ${receipt['elapsed_us'] ?? ''} µs';
  }
}

final class _MeaningText {
  const _MeaningText(this.language);
  final String language;
  String pick(String en, String it, String ru) => switch (language) {
    'it' => it,
    'ru' => ru,
    _ => en,
  };
  String get title => pick(
    'Try a reversible change',
    'Prova una modifica reversibile',
    'Попробуйте обратимое изменение',
  );
  String get instruction => pick(
    'Preview a new ending for this greeting before changing it.',
    'Visualizza una nuova conclusione per questo saluto prima di modificarlo.',
    'Посмотрите новое окончание приветствия перед изменением.',
  );
  String get preview => pick('Preview', 'Anteprima', 'Предпросмотр');
  String get previewAgain =>
      pick('Preview again', 'Nuova anteprima', 'Новый предпросмотр');
  String get apply => pick('Apply', 'Applica', 'Применить');
  String get undo => pick('Undo', 'Annulla modifica', 'Отменить изменение');
  String get current =>
      pick('Current result', 'Risultato attuale', 'Текущий результат');
  String get before => pick('Before', 'Prima', 'До');
  String get after =>
      pick('After this change', 'Dopo questa modifica', 'После изменения');
  String get unknown => pick(
    'The current result could not be confirmed.',
    'Non è stato possibile confermare il risultato attuale.',
    'Не удалось подтвердить текущий результат.',
  );
  String get working => pick(
    'Checking the change…',
    'Verifica della modifica…',
    'Проверка изменения…',
  );
  String get details => pick('Details', 'Dettagli', 'Подробности');
  String get status =>
      pick('Check status', 'Verifica stato', 'Проверить состояние');
  String get finalize => pick(
    'Discard undo history',
    'Elimina la possibilità di annullare',
    'Удалить историю отмены',
  );
  String observation(Object? value) {
    if (value is List) {
      return value
          .map((item) {
            if (item is Map && item.containsKey('value')) {
              final name = item['name'];
              final label = name == ''
                  ? pick('(empty name)', '(nome vuoto)', '(пустое имя)')
                  : '$name';
              return '$label → ${item['value']}';
            }
            return '$item';
          })
          .join('\n');
    }
    return value == null
        ? pick('Not observed yet', 'Non ancora osservato', 'Ещё не наблюдалось')
        : '$value';
  }

  String refusal(String code) {
    if (code.contains('unknown') || code.contains('unsettled')) {
      return pick(
        'The result is uncertain. It has not been replayed.',
        'Il risultato è incerto. La modifica non è stata ripetuta.',
        'Результат неясен. Изменение не повторялось.',
      );
    }
    if (code.contains('drift') || code.contains('stale')) {
      return pick(
        'The source changed. Preview the current version before applying.',
        'Il codice è cambiato. '
            'Visualizza la versione attuale prima di applicare.',
        'Исходный код изменился. Сначала посмотрите текущую версию.',
      );
    }
    if (code.contains('denied') ||
        code.contains('rejected') ||
        code.contains('consent')) {
      return pick(
        'The change was not approved. You can preview again.',
        'La modifica non è stata approvata. '
            'Puoi visualizzare una nuova anteprima.',
        'Изменение не одобрено. Можно создать новый предпросмотр.',
      );
    }
    if (code.contains('open') || code.contains('status_required')) {
      return pick(
        'A previous change still needs to be resolved. See Details.',
        'Una modifica precedente deve ancora essere risolta. Vedi Dettagli.',
        'Предыдущее изменение ещё не завершено. Смотрите подробности.',
      );
    }
    if (code.contains('verification') || code.contains('compiler')) {
      return pick(
        'The change did not pass its checks.',
        'La modifica non ha superato le verifiche.',
        'Изменение не прошло проверки.',
      );
    }
    return pick(
      'This action could not be completed. See Details.',
      'Non è stato possibile completare l’azione. Vedi Dettagli.',
      'Не удалось завершить действие. Смотрите подробности.',
    );
  }
}

/// Plain text disclosure on the document grid, without ListTile chrome.
final class MeaningEvidenceDetails extends StatefulWidget {
  const MeaningEvidenceDetails({
    required this.title,
    this.body,
    this.child,
    this.surfaceKey,
    super.key,
  });
  final String title;
  final String? body;
  final Widget? child;
  final Key? surfaceKey;
  @override
  State<MeaningEvidenceDetails> createState() => _MeaningEvidenceDetailsState();
}

class _MeaningEvidenceDetailsState extends State<MeaningEvidenceDetails>
    with AutomaticKeepAliveClientMixin {
  bool expanded = false;
  @override
  bool get wantKeepAlive => expanded;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          key: widget.surfaceKey,
          onPressed: () {
            setState(() => expanded = !expanded);
            updateKeepAlive();
          },
          child: Text('${expanded ? '−' : '+'} ${widget.title}'),
        ),
        if (expanded) ...[
          if (widget.child != null) widget.child!,
          if (widget.body != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                primary: false,
                child: SelectableText(
                  widget.body!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
