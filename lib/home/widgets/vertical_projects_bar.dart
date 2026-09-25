import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class VerticalProjectsBar extends StatelessWidget {
  const VerticalProjectsBar({
    required this.onIdeaTap,
    required this.onNoteTap,
    super.key,
  });
  final VoidCallback onIdeaTap;
  final VoidCallback onNoteTap;
  @override
  Widget build(final BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 22),
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Wrap(
      direction: Axis.vertical,
      spacing: 16,
      children: [
        BarItem(
          onTap: onIdeaTap,
          label: context.l10n.idea,
          child: IconIdeaButton(onTap: onIdeaTap),
        ),
        BarItem(
          onTap: onNoteTap,
          label: context.l10n.note,
          child: IconButton(
            onPressed: onNoteTap,
            icon: const Icon(Icons.book),
          ),
        ),
      ],
    ),
  );
}

class BarItem extends StatelessWidget {
  const BarItem({
    required this.onTap,
    required this.child,
    required this.label,
    super.key,
  });
  final VoidCallback onTap;
  final Widget child;
  final String label;
  @override
  Widget build(final BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 50, child: child),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 40),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    ),
  );
}
