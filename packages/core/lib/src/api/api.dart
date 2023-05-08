import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core.dart';

export 'clients/clients.dart';
export 'implementations/implementations.dart';
export 'interfaces/interfaces.dart';

class RemoteApiServices {
  const RemoteApiServices._({
    required this.projects,
    required this.user,
  });
  @useResult
  static Future<RemoteApiServices> get v1 async {
    final userApi = UserApiRemoteServiceFirebaseImpl();
    return RemoteApiServices._(
      projects: ProjectsApiRemoteServiceFirebaseImpl(),
      user: userApi,
    );
  }

  final ProjectsApiService projects;
  final UserApiRemoteService user;
}

class LocalApiServices {
  const LocalApiServices._({
    required this.localApi,
    required this.appSettings,
  });

  @useResult
  static Future<LocalApiServices> get v1 async {
    final localApi = LocalApiServiceSharedPreferencesImpl();
    return LocalApiServices._(
      localApi: localApi,
      appSettings: AppSettingsApiLocalService(
        localApiService: localApi,
      ),
    );
  }

  final LocalApiService localApi;
  final AppSettingsApiLocalService appSettings;
}
