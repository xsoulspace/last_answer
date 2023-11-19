import 'package:lastanswer/_library/widgets/buttons/adaptive_back_button.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features_widgets/my_account.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({
    required this.onBack,
    super.key,
  });
  final VoidCallback onBack;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        leading: AdaptiveBackButton(onPressed: onBack),
        title: Text(context.l10n.myAccount),
      ),
      body: const MyAccount(),
    );
  }
}
