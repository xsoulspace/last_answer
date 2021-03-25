import 'package:flutter/material.dart';

class CardDissmisible extends StatelessWidget {
  final Key key;
  final void Function(DismissDirection)? onDismissed;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final Widget child;
  CardDissmisible(
      {required this.child,
      required this.key,
      this.confirmDismiss,
      this.onDismissed});
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      child: child,
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      direction: DismissDirection.horizontal,
      background: Container(
          padding: EdgeInsets.only(right: 12),
          alignment: Alignment.centerLeft,
          color: Colors.red[900],
          child: Icon(Icons.delete, color: Colors.white)),
      secondaryBackground: Container(),
    );
  }
}
