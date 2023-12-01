import 'package:lastanswer/common_imports.dart';

class SettingsText extends StatelessWidget {
  const SettingsText({
    required this.text,
    super.key,
  });
  final String text;
  @override
  Widget build(final BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      );
}
