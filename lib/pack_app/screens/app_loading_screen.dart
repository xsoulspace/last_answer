import 'package:intl/intl.dart' as intl;
import 'package:lastanswer/common_imports.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    super.key,
  });
  @override
  Widget build(final BuildContext context) {
    final appLoadingStatus =
        context.select<GlobalStateNotifier, AppStateLoadingStatuses>(
      (final c) => c.value.appLoadingStatus,
    );
    final statusText = appLoadingStatusesTitlesData[appLoadingStatus]
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
