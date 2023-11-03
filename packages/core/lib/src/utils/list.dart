part of 'utils.dart';

extension ListExtension on List<BasicProject> {
  void sortByDate() => sort(
        (final a, final b) => b.updated.compareTo(a.updated),
      );
}
