import 'app_settings_persistence_service.dart';
import 'local_data_service.dart';

export 'analytics/analytics.dart';
export 'app_settings_persistence_service.dart';

class ServicesCollection {
  const ServicesCollection._({
    required this.localDataService,
    required this.appSettingsPersistence,
  });

  static final v1 = () {
    final LocalDataService localDataService = SharedPreferencesDataService();
    return ServicesCollection._(
      localDataService: localDataService,
      appSettingsPersistence: AppSettingsPersistenceService(
        localDataService: localDataService,
      ),
    );
  }();

  final LocalDataService localDataService;
  final AppSettingsPersistenceService appSettingsPersistence;
}
