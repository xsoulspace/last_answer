import 'package:jaspr/jaspr.dart';

class TabBar extends StatelessComponent {
  const TabBar({
    required this.tabs,
    super.key,
  });
  final List<Component> tabs;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      [ul(tabs, classes: 'flex flex-row')],
      classes: 'relative mx-auto max-w-lg w-full overflow-x-auto rounded-full '
          'border-black/5 bg-black/5 p-1 backdrop-blur-2xl',
    );
  }
}

class Tab extends StatelessComponent {
  const Tab({
    this.titleText = '',
    this.title,
    required this.isSelected,
    required this.onClick,
    super.key,
  });
  final VoidCallback onClick;
  final String titleText;
  final Component? title;
  final bool isSelected;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield li([
      button(
        [title ?? text(titleText)],
        classes: 'font-semibold text-stone-500/90',
        onClick: onClick,
      ),
    ], classes: 'w-auto text-nowrap cursor-pointer select-none px-4 py-2');
  }
}
