part of 'utils.dart';

@immutable
class ProjectSharer {
  const ProjectSharer._({required this.context});
  factory ProjectSharer.of(final BuildContext context) => ProjectSharer._(
        context: context,
      );

  final BuildContext context;

  Future<void> share({
    required final BasicProject project,
  }) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final desktop = isDesktop;
    if (desktop) {
      final messenger = ScaffoldMessenger.of(context);
      final data = ClipboardData(text: project.toShareString());
      await Clipboard.setData(data);
      void closeBanner() => messenger.hideCurrentMaterialBanner();

      Future.delayed(const Duration(seconds: 3), closeBanner);
      messenger.showMaterialBanner(
        MaterialBanner(
          content: const Text('Your project was copied into clipboard!'),
          leading: const Icon(Icons.done),
          backgroundColor: AppColors.primary2.withOpacity(0.2),
          actions: [
            TextButton(
              onPressed: closeBanner,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    } else {
      await Share.share(
        project.toShareString(),
        subject: project.title,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    }
  }
}

abstract class Sharable {
  Sharable._();
  String toShareString();
}
