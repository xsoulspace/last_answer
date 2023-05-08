import '../../../models/models.dart';
import 'local_api_service.dart';

/// The purpose of the service is to get | set information about
/// application wide user settings like locale, etc
class AppSettingsApiLocalService {
  AppSettingsApiLocalService({
    required this.localApiService,
  });
  final LocalApiService localApiService;
  static const _persistenceKey = 'settings';
  Future<void> saveSettings({
    required final AppSettingsModel settings,
  }) async {
    await localApiService.setMap(_persistenceKey, settings.toJson());
  }

  Future<AppSettingsModel> loadSettings() async {
    final jsonMap = await localApiService.getMap(_persistenceKey);
    if (jsonMap.isEmpty) return AppSettingsModel.empty;
    try {
      return AppSettingsModel.fromJson(jsonMap);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // TODO(arenukvern): ignore this error but handle it in future
      return AppSettingsModel.empty;
    }
  }
}
