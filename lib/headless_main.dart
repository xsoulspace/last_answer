import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:lastanswer/coding_agent/headless_product_cli.dart';

/// Native Flutter entrypoint: registered plugins retain the ordinary app's
/// protected account store. No widget tree or second agent loop is created.
void main() {
  unawaited(
    runZonedGuarded<Future<void>>(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await HeadlessProductCli().run();
        exit(0);
      },
      (error, stack) {
        stderr.writeln('Last Answer CLI failed (${error.runtimeType}).');
        exit(1);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => stderr.writeln(line),
      ),
    ),
  );
}
