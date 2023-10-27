part of pack_settings;

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    required this.title,
    required this.child,
    required this.leftColumnWidth,
    this.addTitleQuote = true,
    this.description = '',
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });
  final double leftColumnWidth;
  final String title;
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
          child: Text(
            addTitleQuote ? '$title:' : title,
            textAlign: TextAlign.end,
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
