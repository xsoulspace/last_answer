import 'package:lastanswer/common_imports.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    required this.child,
    required this.leftColumnWidth,
    this.titleText = '',
    this.title,
    this.addTitleQuote = true,
    this.description = '',
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });
  final double leftColumnWidth;
  final String titleText;
  final Widget? title;
  final Widget child;
  final bool addTitleQuote;
  final String description;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox(
          width: leftColumnWidth,
          child: DefaultTextStyle.merge(
            textAlign: TextAlign.end,
            child: title ?? Text(addTitleQuote ? '$titleText:' : titleText),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              child,
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: SelectableText(
                    description,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
