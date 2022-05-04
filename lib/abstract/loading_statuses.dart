part of abstract;

enum AppStateLoadingStatuses {
  settings,
  emoji,
  ideas,
  questionsForAnswers,
  answersForIdeas,
  notes,
  migratingOldData,
}
const appLoadingStatusesTitles = <AppStateLoadingStatuses, LocalizedText>{
  AppStateLoadingStatuses.answersForIdeas: LocalizedText(
    en: '✨ Loading answers for ideas..',
    ru: '✨ Ответы идей загружаются..',
    it: '✨ Caricamento risposte per idee..',
  ),
  AppStateLoadingStatuses.emoji: LocalizedText(
    en: '✨ Loading emojis..',
    ru: '✨ Загружаются смайлики..',
    it: '✨ Caricamento emoji..',
  ),
  AppStateLoadingStatuses.ideas: LocalizedText(
    en: '✨ Loading ideas..',
    ru: '✨ Загружаются идеи..',
    it: '✨ Caricamento idee..',
  ),
  AppStateLoadingStatuses.migratingOldData: LocalizedText(
    en: '✨ Migrating old data..',
    ru: '✨ Обновляем старые данные..',
    it: '✨ Migrazione di vecchi dati..',
  ),
  AppStateLoadingStatuses.notes: LocalizedText(
    en: '✨ Loading notes..',
    ru: '✨ Заметки загружаются..',
    it: '✨ ',
  ),
  AppStateLoadingStatuses.questionsForAnswers: LocalizedText(
    en: '✨ Loading questions for answers..',
    ru: '✨ Загружаются вопросы для ответов..',
    it: '✨ Caricamento note..',
  ),
  AppStateLoadingStatuses.settings: LocalizedText(
    en: '✨ Loading settings..',
    ru: '✨ Загружаются настройки..',
    it: '✨ Caricamento impostazioni..',
  ),
};
