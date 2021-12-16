part of pack_app;

class _VerticalProjectsBar extends StatelessWidget {
  const _VerticalProjectsBar({
    required final this.onIdeaTap,
    required final this.onNoteTap,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onIdeaTap;
  final VoidCallback onNoteTap;
  @override
  Widget build(final BuildContext context) {
    final themeDefiner = ThemeDefiner.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: 6,
        right: 6,
        bottom: 8,
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
    required final this.onTap,
    required final this.child,
    required final this.label,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onTap;
  final Widget child;
  final String label;
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
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
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
