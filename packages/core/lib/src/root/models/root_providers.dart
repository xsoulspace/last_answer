part of 'models.dart';

@freezed
class RootProvidersModel with _$RootProvidersModel {
  const factory RootProvidersModel({
    required final Create<RepositoriesCollection> repositories,
    required final Create<AnalyticsService> analyticsService,
    required final Create<RemoteApiServices> remoteApiServices,
    required final Create<LocalApiServices> localApiServices,
    required final Create<UserNotifier> userNotifier,
  }) = _RootProvidersModel;

  factory RootProvidersModel.appRuntime({
    required final GlobalInitializer globalInitializer,
  }) =>
      RootProvidersModel(
        localApiServices: (final context) => LocalApiServices.buildAppRuntime(),
        remoteApiServices: (final context) =>
            RemoteApiServices.buildAppRuntime(),
        repositories: (final context) => RepositoriesCollection(
          user: UserRepository(sources: RepositoryDataSources.of(context)),
        ),
        analyticsService: (final context) => globalInitializer.analyticsService,
        userNotifier: (final context) => UserNotifier(
          repositories: context.read(),
        ),
      );

  factory RootProvidersModel.mock({
    required final GlobalInitializer globalInitializer,
  }) =>
      RootProvidersModel(
        localApiServices: (final context) =>
            LocalApiServices.buildMockRuntime(),
        remoteApiServices: (final context) =>
            RemoteApiServices.buildMockRuntime(),
        repositories: (final context) => RepositoriesCollection(
          user: UserRepository(sources: RepositoryDataSources.of(context)),
        ),
        analyticsService: (final context) => globalInitializer.analyticsService,
        userNotifier: (final context) => UserNotifier(
          repositories: context.read(),
        ),
      );
}
