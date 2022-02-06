part of widgets;

class RightScrollbar extends StatelessWidget {
  const RightScrollbar({
    required final this.child,
    required final this.controller,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  final ScrollController controller;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scrollbar(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Theme(
          data: theme.copyWith(
            scrollbarTheme: theme.scrollbarTheme.copyWith(
              crossAxisMargin: -10,
              thumbColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
