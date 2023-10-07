import 'package:lastanswer/abstract/abstract.dart';

extension ListExtension on List<BasicProject> {
  void sortByDate() => sort(
        (final a, final b) => b.updatedAt.compareTo(a.updatedAt),
      );
}
