import 'dart:io';

import 'package:flutter/material.dart';
import 'package:howtosolvequest/components/CustomDialogComponent.dart';
import 'package:howtosolvequest/components/htmlSaveFileComponent.dart';
import 'package:howtosolvequest/localizations/MainLocalizations.dart';
import 'package:howtosolvequest/models/AnswersModel.dart';
import 'package:howtosolvequest/models/LocaleModel.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);

    cancelButton() {
      return RaisedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(MainLocalizations.of(context).newQuestCancel),
      );
    }

    startButton() {
      return RaisedButton(
        onPressed: () {
          Provider.of<AnswersModel>(context).clearAll();
          Navigator.pushNamed(context, '/');
        },
        child: Text(MainLocalizations.of(context).newQuestStart),
        color: Theme.of(context).buttonTheme.colorScheme.error,
      );
    }

    buttonStart() {
      return IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  Consumer<LocaleModel>(builder: (context, locale, child) {
                    return CustomDialog(
                        title: MainLocalizations.of(context).newQuest,
                        description: MainLocalizations.of(context).newQuestDesc,
                        leftButton: cancelButton(),
                        rightButton: startButton());
                  }));

          // Navigator.pushNamed(context, '/');
        },
        icon: Icon(Icons.add),
      );
    }

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SaveFile(),
            buttonStart(),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ],
        ),
        Divider(
          color: Theme.of(context).primaryColor,
        ),
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

class SaveFile extends StatefulWidget {
  @override
  _SaveFileState createState() => _SaveFileState();
}

class _SaveFileState extends State<SaveFile> {
  _SaveFileState();

  @override
  Widget build(BuildContext context) {
    saveAsWeb() async {
      final h = HtmlSaveFileComponent(context);
      await h.saveInWeb();

      // await SimplePermissions.requestPermission(
      //     Permission.WriteExternalStorage);
      // bool checkPermission = await SimplePermissions.checkPermission(
      //     Permission.WriteExternalStorage);
      // if (checkPermission) {
      //   //store file in documents folder

      //   String dir =
      //       (await getExternalStorageDirectory()).absolute.path + "/documents";
        // File f = new File("./filename.csv");
        // var sink = f.openWrite();
        // sink.write('FILE ACCESSED ${new DateTime.now()}\n');
        // sink.close();
      // }
    }

    return Row(
      children: <Widget>[
        FlatButton(
            onPressed: () {
              saveAsWeb();
            },
            child: Text(MainLocalizations.of(context).save)),
      ],
    );
  }
}
