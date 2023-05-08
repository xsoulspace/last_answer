import '../../core.dart';

export 'clients/clients.dart';
export 'implementations/implementations.dart';
export 'interfaces/interfaces.dart';

class RemoteApiServices {
  const RemoteApiServices._({
    required this.projects,
    required this.user,
  });
  factory RemoteApiServices.buildAppRuntime() {
    final userApi = UserApiRemoteServiceFirebaseImpl();
    return RemoteApiServices._(
      projects: ProjectsApiRemoteServiceFirebaseImpl(),
      user: userApi,
    );
  }
  factory RemoteApiServices.buildMockRuntime() {
    // TODO(arenukvern): description
    throw UnimplementedError('reason');
  }

  final ProjectsApiService projects;
  final UserApiRemoteService user;
}

class LocalApiServices {
  const LocalApiServices._({
    required this.localApi,
    required this.appSettings,
  });

  factory LocalApiServices.buildAppRuntime() {
    final localApi = LocalApiServiceSharedPreferencesImpl();
    return LocalApiServices._(
      localApi: localApi,
      appSettings: AppSettingsApiLocalService(
        localApiService: localApi,
      ),
    );
  }
  factory LocalApiServices.buildMockRuntime() {
    // TODO(arenukvern): description
    throw UnimplementedError('reason');
  }

  final LocalApiService localApi;
  final AppSettingsApiLocalService appSettings;
}
