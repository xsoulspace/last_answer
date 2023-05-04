import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:share_plus/share_plus.dart';

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
    if (DeviceRuntimeType.isDesktop) {
      final messenger = ScaffoldMessenger.of(context);
      final data = ClipboardData(text: project.toShareString(context));
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
        project.toShareString(context),
        subject: project.title,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    }
  }
}

abstract class Sharable {
  Sharable._();
  String toShareString(final BuildContext context);
}
