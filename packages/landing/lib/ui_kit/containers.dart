import 'package:jaspr/jaspr.dart';

class Card extends StatelessComponent {
  const Card(this.children, {this.classes = '', super.key});
  final List<Component> children;
  final String classes;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(children,
        classes: 'rounded-[64px] border '
            'border-stone-100/80 bg-white/90 p-8 md:p-24 '
            '$classes flex flex-col items-start text-left');
  }
}

class BentoGrid extends StatelessComponent {
  const BentoGrid({required this.cards, super.key});
  final List<Component> cards;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(cards,
        classes:
            'grid grid-flow-row-dense grid-cols-1 sm:grid-cols-1 gap-16 md:gap-24');
  }
}
