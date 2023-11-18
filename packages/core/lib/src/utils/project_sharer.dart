import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core.dart';
import 'platform_info.dart';

@immutable
class ProjectSharer {
  const ProjectSharer._({required this.context});
  factory ProjectSharer.of(final BuildContext context) => ProjectSharer._(
        context: context,
      );

  final BuildContext context;

  Future<void> share({
    required final Sharable sharable,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final isDesktop = PlatformInfo.isNativeWebDesktop;
    if (isDesktop) {
      final messenger = ScaffoldMessenger.of(context);
      final data = ClipboardData(text: sharable.toShareString());
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
        sharable.toShareString(),
        subject: sharable.sharableTitle,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    }
  }
}

abstract interface class Sharable {
  Sharable._();
  String toShareString();
  abstract final String sharableTitle;
}

abstract interface class Archivable {
  Archivable._();
  abstract final DateTime? archivedAt;
}
