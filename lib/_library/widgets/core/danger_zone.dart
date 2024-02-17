part of '../widgets.dart';

class DangerZone extends StatelessWidget {
  const DangerZone({
    required this.onRemove,
    this.removeText,
    this.dangerBackgroundColor,
    this.isLoading = false,
    super.key,
  });
  final VoidCallback onRemove;
  final Color? dangerBackgroundColor;
  final String? removeText;
  final bool isLoading;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: defaultPopupBorderRadius,
              border: Border.all(color: AppColors.accent2),
            ),
            height: 50,
          ),
        ),
        Positioned(
          top: 0,
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: defaultPopupBorderRadius,
              color: dangerBackgroundColor ?? theme.canvasColor.withOpacity(1),
            ),
            child: Text(
              context.l10n.danger,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.accent3,
              ),
            ),
          ),
        ),
        Positioned.fill(
          top: 15,
          child: RemoveActionButton(
            onTap: onRemove,
            text: removeText,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
