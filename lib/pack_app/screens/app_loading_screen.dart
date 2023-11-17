import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    super.key,
  });
  @override
  Widget build(final BuildContext context) {
    final settings = context.watch<GeneralSettingsController>();
    final statusText = appLoadingStatusesTitlesData[settings.loadingStatus]
            ?.getByLanguage(intl.Intl.systemLocale) ??
        '';

    return ColoredBox(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary2),
            ),
            const SizedBox(height: 5),
            Text(statusText),
          ],
        ),
      ),
    );
  }
}
