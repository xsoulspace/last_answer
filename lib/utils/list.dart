part of utils;

extension ListExtension on List<BasicProject> {
  void sortByDate() => sort(
        (final a, final b) => a.updated.compareTo(b.updated),
      );
}
