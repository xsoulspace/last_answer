import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/abstract/current_state_keys.dart';
import 'package:lastanswer/abstract/project.dart';

class AppStoreInitializer extends StatelessWidget {
  const AppStoreInitializer({
    final Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<bool>(
      future: (() async {
        await Hive.initFlutter();
        // await Hive.deleteBoxFromDisk(HiveBoxes.projects);
        // await Hive.deleteBoxFromDisk(HiveBoxes.answers);
        await Hive.openBox<bool>(HiveBoxes.darkMode);
        await Hive.openBox<Project>(HiveBoxes.projects);
        await Hive.openBox<Answer>(HiveBoxes.answers);
        return true;
      })(),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // TODO: replace to Circular loader
          return Container();
        }
        return child;
      },
    );
  }
}
