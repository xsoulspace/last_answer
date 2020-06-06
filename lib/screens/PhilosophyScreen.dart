import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhilosophyScreen extends StatefulWidget {
  @override
  _PhilosophyScreenState createState() => _PhilosophyScreenState();
}

class _PhilosophyScreenState extends State<PhilosophyScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          Spacer(),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Philosophy')],
          )
        ]));
  }
}
