//https://medium.com/@excogitatr/custom-dialog-in-flutter-d00e0441f1d5

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Consts {
  Consts._();

  static const double padding = 16.0;
}

class CustomDialog extends StatelessWidget {
  final String title, description;
  final Widget rightButton, leftButton;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.rightButton,
    this.leftButton,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        Consts.padding,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(Consts.padding),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              leftButton,
              rightButton
            ],
          ),
        ],
      ),
    );
  }
}
