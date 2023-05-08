part of 'models.dart';

@freezed
class AppProvidersModel with _$AppProvidersModel {
  const factory AppProvidersModel({
    required final AnalyticsService analyticsService,
  }) = _AppProvidersModel;

  factory AppProvidersModel.appRuntime({
    required final AppDiServicesDto diDto,
  }) =>
      AppProvidersModel(
        analyticsService: diDto.analyticsService,
      );
  factory AppProvidersModel.mock({
    required final AppDiServicesDto diDto,
  }) =>
      AppProvidersModel(
        analyticsService: diDto.analyticsService,
      );
}
