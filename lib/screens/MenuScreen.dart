import 'package:flutter/material.dart';
import 'package:howtosolvequest/localizations/MainLocalizations.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
                onPressed: null,
                child: Text(MainLocalizations.of(context).save)),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              icon: Icon(Icons.add),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ],
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  MainLocalizations.load(Locale('ru', 'RU'));
                },
                child: Text("Rus")),
            FlatButton(
                onPressed: () {
                  MainLocalizations.load(Locale('en', 'EN'));
                },
                child: Text("Eng")),
          ],
        )
      ],
    ));
  }
}
