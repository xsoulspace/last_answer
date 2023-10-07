import 'package:core/core.dart';
import 'package:lastanswer/navigation/navigation.dart';

Future<void> main() async => bootstrapMain(
      builder: (final context) => AppScaffold(
        goRouter: GoRouterBuilder.create(),
      ),
    );
