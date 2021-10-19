part of utils;

@immutable
class ProjectSharer {
  const ProjectSharer._({required final this.context});
  factory ProjectSharer.of(final BuildContext context) => ProjectSharer._(
        context: context,
      );

  final BuildContext context;

  Future<void> share({
    required final BasicProject project,
  }) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    await Share.share(
      project.toShareString(),
      subject: project.title,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }
}

abstract class Sharable {
  Sharable._();
  String toShareString();
}
