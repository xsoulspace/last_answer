import 'package:flutter/material.dart';

class CardDissmisible extends StatelessWidget {
  final void Function(DismissDirection)? onDismissed;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final Widget child;
  const CardDissmisible({
    required this.child,
    required this.dismissableKey,
    this.confirmDismiss,
    this.onDismissed,
  });
  final Key dismissableKey;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissableKey,
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      background: Container(
        padding: const EdgeInsets.only(right: 12),
        alignment: Alignment.centerLeft,
        color: Colors.red[900],
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(),
      child: child,
    );
  }
}
