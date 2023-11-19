import 'package:lastanswer/common_imports.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    // final size = MediaQuery.sizeOf(context);
    // return ConstrainedBox(
    //   constraints: BoxConstraints(
    //     maxHeight: size.height,
    //     maxWidth: size.width,
    //   ),
    //   child: const UpdateNotificationDialog(),
    // );
    return Center(
      child: OutlinedButton(
        child: const Text('To home'),
        onPressed: () => context.go(ScreenPaths.home),
      ),
    );
  }
}
