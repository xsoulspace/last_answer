import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/abstract.dart';

class AppStoreInitializer extends StatelessWidget {
  const AppStoreInitializer({
    required final this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(final BuildContext context) => FutureBuilder<bool>(
        future: (() async {
          await Hive.initFlutter();
          // TODO(arenukvern): remove old stores after migration
          // await Hive.deleteBoxFromDisk(HiveBoxes.projects);
          // await Hive.deleteBoxFromDisk(HiveBoxes.answers);
          await Hive.openBox<bool>(HiveBoxesIds.darkModeKey);
          await Hive.openBox<Project>(HiveBoxesIds.projectsKey);
          await Hive.openBox<Answer>(HiveBoxesIds.answersKey);
          return true;
        })(),
        builder: (final context, final snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // TODO(arenukvern): replace with loader
            return Container();
          }
          return child;
        },
      );
}
