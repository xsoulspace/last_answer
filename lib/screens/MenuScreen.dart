import 'package:flutter/material.dart';
import 'package:howtosolvequest/components/CustomDialogComponent.dart';
import 'package:howtosolvequest/localizations/MainLocalizations.dart';
import 'package:howtosolvequest/models/LocaleModel.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);

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
                showDialog(
                  context: context,
                  builder: (BuildContext context) => CustomDialog(
                    title: "Success",
                    description:
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    leftButton: RaisedButton(onPressed: null, child: Text('')),
                    rightButton: RaisedButton(onPressed: null, child: Text('')) 
                  ),
                );

                // Navigator.pushNamed(context, '/');
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
                  localeModel.switchLang(Locale('ru', 'RU'));
                },
                child: Text("Rus")),
            FlatButton(
                onPressed: () {
                  localeModel.switchLang(Locale('en', 'EN'));
                },
                child: Text("Eng")),
          ],
        ),
        // Divider(),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     FlatButton(
        //         onPressed: () {
        //           localeModel.switchLang(Locale('ru', 'RU'));
        //         },
        //         child: Text("Dark")),
        //     FlatButton(
        //         onPressed: () {
        //           localeModel.switchLang(Locale('en', 'EN'));
        //         },
        //         child: Text("Light")),
        //   ],
        // )
      ],
    ));
  }
}
