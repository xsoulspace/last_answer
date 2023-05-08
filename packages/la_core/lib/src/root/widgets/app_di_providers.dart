import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../services/services.dart';
import '../../states/states.dart';

part 'app_di_services_dto.dart';

typedef AppWidgetBuilder = Widget Function(BuildContext, AppRouter);

class AppDiProviders extends StatelessWidget {
  const AppDiProviders._({
    required this.diDto,
    required this.builder,
  });
  static Widget Function(AppDiServicesDto) createFor(
    final AppWidgetBuilder builder,
  ) =>
      (final diDto) => AppDiProviders._(
            diDto: diDto,
            builder: builder,
          );

  final AppDiServicesDto diDto;
  final AppWidgetBuilder builder;

  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: const [],
      );
}
