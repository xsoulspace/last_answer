import '../data_models/data_models.dart';

enum AppStateLoadingStatuses {
  settings,
  emoji,
  migratingOldData,
  completed;
}

const appLoadingStatusesTitlesData =
    <AppStateLoadingStatuses, LocalizedTextModel>{
  AppStateLoadingStatuses.emoji: LocalizedTextModel(
    en: 'Loading emojis ✨',
    ru: 'Загружаются смайлики ✨',
    it: 'Caricamento emoji',
  ),
  AppStateLoadingStatuses.migratingOldData: LocalizedTextModel(
    en: 'Migrating old data ✨',
    ru: 'Обновляем старые данные ✨',
    it: 'Migrazione di vecchi dati',
  ),
  AppStateLoadingStatuses.settings: LocalizedTextModel(
    en: 'Loading settings ✨',
    ru: 'Загружаются настройки ✨',
    it: 'Caricamento impostazioni',
  ),
};
