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
    final theme = context.laUi;
    final labelWidget =
        title ?? Text(addTitleQuote ? '$titleText:' : titleText);
    final control = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: LaSelectableText(
              description,
              style: theme.compact.copyWith(color: theme.inkMuted),
            ),
          ),
      ],
    );

    // A narrow split pane stacks the label above the control instead of
    // keeping the fixed label column (a crushed pane squeezed the row
    // past its label width and overflowed — live-caught reverify,
    // 2026-11-17). The fixed-column two-line form is the WIDE layout.
    return LayoutBuilder(
      builder: (final context, final constraints) {
        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle.merge(
                textAlign: TextAlign.start,
                child: labelWidget,
              ),
              const SizedBox(height: 6),
              control,
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            SizedBox(
              width: leftColumnWidth,
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.end,
                child: labelWidget,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: control),
          ],
        );
      },
    );
  }
}
