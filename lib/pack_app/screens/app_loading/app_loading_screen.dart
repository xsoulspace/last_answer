part of pack_app;

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    final Key? key,
  }) : super(key: key);
  @override
  Widget build(final BuildContext context) {
    final settings = SettingsStateScope.of(context);
    final statusText = appLoadingStatusesTitles[settings.loadingStatus]
            ?.getByLanguage(intl.Intl.systemLocale) ??
        '';
    return Container(
      color: AppColors.black,
      child: Center(
        child: Directionality(
          textDirection: TextDirection.ltr,
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
      ),
    );
  }
}
