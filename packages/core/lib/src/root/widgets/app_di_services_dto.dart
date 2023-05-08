part of 'app_di_providers.dart';

class AppDiServicesDto {
  AppDiServicesDto._({
    required this.analyticsService,
  });
  factory AppDiServicesDto.fromInitializer(
    final GlobalInitializer initializer,
  ) =>
      AppDiServicesDto._(
        analyticsService: initializer.analyticsService,
      );

  final AnalyticsService analyticsService;
}
