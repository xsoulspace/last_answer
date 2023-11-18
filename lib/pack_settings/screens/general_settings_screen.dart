import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/buttons/adaptive_back_button.dart';
import 'package:lastanswer/pack_settings/features_widgets/general_settings.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({
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
        title: Text(S.current.generalSettingsFullTitle),
      ),
      body: const GeneralSettingsView(),
    );
  }
}
