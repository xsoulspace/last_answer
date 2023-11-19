import 'package:lastanswer/common_imports.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    super.key,
  });
  @override
  Widget build(final BuildContext context) => Directionality(
        // TODO(arenukvern): replace with default device textDirection
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: AppColors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary2),
                ),
                const SizedBox(height: 5),
                Text(S.of(context).loading),
              ],
            ),
          ),
        ),
      );
}
