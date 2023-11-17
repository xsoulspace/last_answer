import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_purchases/pack_purchases.dart';
import 'package:lastanswer/utils/utils.dart';

class _VerticalProjectsBar extends StatelessWidget {
  const _VerticalProjectsBar({
    required this.onIdeaTap,
    required this.onNoteTap,
  });
  final VoidCallback onIdeaTap;
  final VoidCallback onNoteTap;
  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: 6,
        right: 6,
        bottom: 22,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 6,
        ),
        // TODO(arenukvern): add gradient
        decoration: BoxDecoration(
          borderRadius: defaultBorderRadius,
          color: themeDefiner.themeToUse == ThemeToUse.fromContext
              ? Theme.of(context).splashColor.withOpacity(0.05)
              : null,
        ),
        child: Wrap(
          direction: Axis.vertical,
          spacing: 16,
          children: [
            BarItem(
              onTap: onIdeaTap,
              label: S.current.idea,
              child: IconIdeaButton(
                onTap: onIdeaTap,
              ),
            ),
            BarItem(
              onTap: onNoteTap,
              label: S.current.note,
              child: IconButton(
                onPressed: onNoteTap,
                icon: const Icon(Icons.book),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        child: SizedBox(
          height: 56,
          child: Stack(
            children: [
              SizedBox(
                height: 50,
                child: child,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
}
