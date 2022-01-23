part of pack_app;

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
