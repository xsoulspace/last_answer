import 'package:flutter/widgets.dart';

/// Small feature vocabulary; authored project content is never translated.
String workbenchText(BuildContext context, String value) {
  final language = Localizations.localeOf(context).languageCode;
  final words = _words[value];
  return words == null
      ? value
      : words[language == 'it'
            ? 0
            : language == 'ru'
            ? 1
            : 2];
}

const _words = <String, List<String>>{
  'Saved position could not be restored. Opened at the beginning.': [
    'La posizione salvata non può essere ripristinata. Aperto dall’inizio.',
    'Не удалось восстановить позицию. Документ открыт с начала.',
    'Saved position could not be restored. Opened at the beginning.',
  ],
  'Inspect object': [
    'Oggetto da esaminare',
    'Объект для исследования',
    'Inspect object',
  ],
  'Workbench': ['Spazio di lavoro', 'Рабочее пространство', 'Workbench'],
  'Open sample article': [
    'Crea articolo di esempio',
    'Создать пример статьи',
    'Open sample article',
  ],
  'Inspect': ['Esamina', 'Исследовать', 'Inspect'],
  'Focus writing': [
    'Torna alla scrittura',
    'Вернуться к письму',
    'Focus writing',
  ],
  'Return to writing': [
    'Torna alla scrittura',
    'Вернуться к письму',
    'Return to writing',
  ],
  'Choose project work': [
    'Scegli un progetto',
    'Выбрать проект',
    'Choose project work',
  ],
  'Project opening connection': [
    'Collegamento di apertura',
    'Связь открытия проекта',
    'Project opening connection',
  ],
  'Project opening behaviour': [
    'Comportamento di apertura',
    'Поведение открытия проекта',
    'Project opening behaviour',
  ],
  'Selected work': ['Lavoro selezionato', 'Выбранная работа', 'Selected work'],
  'Select': ['Seleziona', 'Выбрать', 'Select'],
  'Move up': ['Sposta in alto', 'Переместить выше', 'Move up'],
  'Move down': ['Sposta in basso', 'Переместить ниже', 'Move down'],
  'Split at cursor': [
    'Dividi al cursore',
    'Разделить у курсора',
    'Split at cursor',
  ],
  'supports': ['supporta', 'подтверждает', 'supports'],
  'contradicts': ['contraddice', 'противоречит', 'contradicts'],
  'unresolved': ['da verificare', 'не проверено', 'unresolved'],
  'Restore position': [
    'Ripristina posizione',
    'Восстановить место',
    'Restore position',
  ],
  'Focus editor': ['Attiva editor', 'Перейти в редактор', 'Focus editor'],
  'Stage behaviour': [
    'Prepara modifica',
    'Подготовить изменение',
    'Stage behaviour',
  ],
  'Leave (save position)': [
    'Esci e salva posizione',
    'Выйти, сохранив место',
    'Leave (save position)',
  ],
  'Reopen with candidate': [
    'Riapri con proposta',
    'Открыть с предложением',
    'Reopen with candidate',
  ],
  'Reopen project': ['Riapri progetto', 'Открыть проект', 'Reopen project'],
  'Adopt': ['Applica', 'Применить', 'Adopt'],
  'Reject': ['Rifiuta', 'Отклонить', 'Reject'],
  'Undo': ['Annulla', 'Отменить', 'Undo'],
  'Reapply': ['Ripropone', 'Предложить снова', 'Reapply'],
  'Previous': ['Precedente', 'Назад', 'Previous'],
  'Next': ['Successivo', 'Вперёд', 'Next'],
  'document': ['documento', 'документ', 'document'],
  'spatial': ['spaziale', 'пространство', 'spatial'],
  'runtime': ['esecuzione', 'исполнение', 'runtime'],
  'Live harness session': [
    'Sessione harness attiva',
    'Активная сессия harness',
    'Live harness session',
  ],
  'Share selected scope and investigate': [
    'Condividi selezione e ricerca',
    'Передать выбранное для исследования',
    'Share selected scope and investigate',
  ],
  'Evidence source (URL or project reference)': [
    'Fonte (URL o riferimento)',
    'Источник (URL или ссылка на проект)',
    'Evidence source (URL or project reference)',
  ],
  'Question or change intent': [
    'Domanda o intento',
    'Вопрос или цель изменения',
    'Question or change intent',
  ],
  'Proposals · adoption changes this project': [
    'Proposte · applicare modifica il progetto',
    'Предложения · применение изменяет проект',
    'Proposals · adoption changes this project',
  ],
  'Recorded observations · stepping does not re-execute': [
    'Osservazioni registrate · senza riesecuzione',
    'Записанные наблюдения · без повторного исполнения',
    'Recorded observations · stepping does not re-execute',
  ],
};
