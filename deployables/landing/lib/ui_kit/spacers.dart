import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// will use m-{value} to define spacing
class TwSpacer extends StatelessComponent {
  const TwSpacer.x(final String value, {super.key}) : value = 'mr-$value';
  const TwSpacer.y(final String value, {super.key}) : value = 'mt-$value';
  final String value;
  @override
  Component build(BuildContext context) {
    return div([], classes: value);
  }
}
