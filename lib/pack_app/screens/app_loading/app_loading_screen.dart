import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:provider/provider.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    final Key? key,
  }) : super(key: key);
  @override
  Widget build(final BuildContext context) {
    final settings = context.watch<GeneralSettingsController>();
    final statusText = appLoadingStatusesTitles[settings.loadingStatus]
            ?.getByLanguage(intl.Intl.systemLocale) ??
        '';

    return ColoredBox(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgress(),
            const SizedBox(height: 5),
            Text(statusText),
          ],
        ),
      ),
    );
  }
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(AppColors.primary2),
    );
  }
}
