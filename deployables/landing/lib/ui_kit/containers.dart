import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Row extends StatelessComponent {
  const Row({
    required this.children,
    this.mainAxisAlignment = JustifyContent.center,
    super.key,
  });
  final List<Component> children;
  final JustifyContent mainAxisAlignment;
  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        flexDirection: FlexDirection.row,
        justifyContent: mainAxisAlignment,
      ),
      children,
    );
  }
}

class Card extends StatelessComponent {
  const Card(this.children, {this.classes = '', super.key});
  final List<Component> children;
  final String classes;

  @override
  Component build(BuildContext context) {
    return div(
      children,
      classes:
          'rounded-[64px] border '
          'border-stone-100/80 bg-white/90 p-8 md:p-24 '
          '$classes flex flex-col items-start text-left',
    );
  }
}

class BentoGrid extends StatelessComponent {
  const BentoGrid({required this.cards, super.key});
  final List<Component> cards;
  @override
  Component build(BuildContext context) {
    return div(
      cards,
      classes:
          'grid grid-flow-row-dense grid-cols-1 sm:grid-cols-1 gap-16 md:gap-24',
    );
  }
}
