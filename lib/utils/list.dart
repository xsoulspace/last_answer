part of utils;

extension ListExtension on List<BasicProject> {
  void sortByDate() => sort(
        (final a, final b) => b.updatedAt.compareTo(a.updatedAt),
      );
}
