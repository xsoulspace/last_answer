part of 'models.dart';

@freezed
class RootProvidersModel with _$RootProvidersModel {
  const factory RootProvidersModel({
    required final AnalyticsService analyticsService,
  }) = _RootProvidersModel;

  factory RootProvidersModel.appRuntime({
    required final AppDiServicesDto diDto,
  }) =>
      RootProvidersModel(
        analyticsService: diDto.analyticsService,
      );
  factory RootProvidersModel.mock({
    required final AppDiServicesDto diDto,
  }) =>
      RootProvidersModel(
        analyticsService: diDto.analyticsService,
      );
}
