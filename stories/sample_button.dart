import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ButtonStyles { primary, secondary, disabled }

class Button extends StatelessWidget {
  const Button({
    required this.text,
    required this.style,
    final Key? key,
  }) : super(key: key);
  final String text;
  final ButtonStyles style;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: null,
        style: TextButton.styleFrom(
          primary: getPrimaryColor(),
          backgroundColor: getBackgroundColor(),
          side: style == ButtonStyles.secondary
              ? const BorderSide(width: 0, color: Colors.black87)
              : null,
        ),
        child: Text(text),
      ),
    );
  }

  Color getPrimaryColor() {
    switch (style) {
      case ButtonStyles.primary:
        return Colors.white;
      case ButtonStyles.secondary:
        return Colors.black87;
      case ButtonStyles.disabled:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Color getBackgroundColor() {
    switch (style) {
      case ButtonStyles.primary:
        return Colors.green;
      case ButtonStyles.secondary:
        return Colors.white;
      case ButtonStyles.disabled:
        return const Color(0xFFE0E0E0);
      default:
        return Colors.green;
    }
  }
}
