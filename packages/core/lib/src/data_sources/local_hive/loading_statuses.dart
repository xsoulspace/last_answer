part of 'hive_models.dart';

enum AppStateLoadingStatuses {
  settings,
  emoji,
  ideas,
  questionsForAnswers,
  answersForIdeas,
  notes,
  migratingOldData,
}

const appLoadingStatusesTitles = <AppStateLoadingStatuses, LocalizedTextModel>{
  AppStateLoadingStatuses.answersForIdeas: LocalizedTextModel(
    en: 'Loading answers for ideas ✨',
    ru: 'Ответы идей загружаются ✨',
    it: 'Caricamento risposte per idee',
  ),
  AppStateLoadingStatuses.emoji: LocalizedTextModel(
    en: 'Loading emojis ✨',
    ru: 'Загружаются смайлики ✨',
    it: 'Caricamento emoji',
  ),
  AppStateLoadingStatuses.ideas: LocalizedTextModel(
    en: 'Loading ideas ✨',
    ru: 'Загружаются идеи ✨',
    it: 'Caricamento idee',
  ),
  AppStateLoadingStatuses.migratingOldData: LocalizedTextModel(
    en: 'Migrating old data ✨',
    ru: 'Обновляем старые данные ✨',
    it: 'Migrazione di vecchi dati',
  ),
  AppStateLoadingStatuses.notes: LocalizedTextModel(
    en: 'Loading notes ✨',
    ru: 'Заметки загружаются ✨',
  ),
  AppStateLoadingStatuses.questionsForAnswers: LocalizedTextModel(
    en: 'Loading questions for answers ✨',
    ru: 'Загружаются вопросы для ответов ✨',
    it: 'Caricamento note',
  ),
  AppStateLoadingStatuses.settings: LocalizedTextModel(
    en: 'Loading settings ✨',
    ru: 'Загружаются настройки ✨',
    it: 'Caricamento impostazioni',
  ),
};
