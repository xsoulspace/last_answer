import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'appBarMenuButton',
              child: Material(
                shape: CircleBorder(),
                color: Colors.transparent,
                child: SizedBox(
                  height: 48,
                  width: 56,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
        SafeArea(
            child: Stack(
          children: [
            Hero(
                tag: 'appBarBackground',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    color: Theme.of(context).canvasColor,
                  ),
                ))
          ],
        )),
      ],
    ));
  }
}
