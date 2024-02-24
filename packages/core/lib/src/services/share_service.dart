import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core.dart';
import 'file_service/file_service_i.dart';

@immutable
class ProjectSharer {
  const ProjectSharer.of(this.context);
  final BuildContext context;

  Future<void> share(final Sharable sharable) async =>
      ShareService.of(context).share(
        title: sharable.toSharableTitle(context),
        content: sharable.toShareString(context),
      );
  Future<void> shareProjects(final List<Map<String, dynamic>> json) async =>
      ShareService.of(context).share(
        title: 'Last Answer: ${FileServiceI.filenameWithTimestamp}',
        content: jsonEncode(json),
      );
}

class ShareService {
  ShareService.of(this.context);
  final BuildContext context;

  Future<void> share({
    required final String title,
    required final String content,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final isDesktop = PlatformInfo.isNativeWebDesktop;
    if (isDesktop) {
      final l10n = context.l10n;
      final messenger = ScaffoldMessenger.of(context);
      final data = ClipboardData(text: content);
      await Clipboard.setData(data);
      void closeBanner() => messenger.hideCurrentMaterialBanner();

      Future.delayed(const Duration(seconds: 3), closeBanner);
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(l10n.yourProjectWasCopiedToClipboard),
          leading: const Icon(Icons.done),
          backgroundColor: AppColors.primary2.withOpacity(0.2),
          actions: [
            TextButton(
              onPressed: closeBanner,
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } else {
      await Share.share(
        content,
        subject: title,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    }
  }
}

abstract interface class Sharable {
  Sharable._();
  String toShareString(final BuildContext context);
  String toSharableTitle(final BuildContext context);
}

abstract interface class Archivable {
  Archivable._();
  abstract final DateTime? archivedAt;
}
