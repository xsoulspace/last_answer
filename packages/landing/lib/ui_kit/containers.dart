import 'package:jaspr/jaspr.dart';

class Card extends StatelessComponent {
  const Card(this.children, {this.size = '', super.key});
  final List<Component> children;
  final String size;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(children,
        classes: 'rounded-full border '
            'border-stone-100/80 bg-white/80 p-4 md:p-8 $size flex items-center');
  }
}

class BentoGrid extends StatelessComponent {
  const BentoGrid({required this.cards, super.key});
  final List<Component> cards;
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(cards,
        classes: 'grid grid-flow-row-dense grid-cols-1 sm:grid-cols-2 gap-4');
  }
}
