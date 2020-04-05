import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvequest/components/CustomDialogComponent.dart';
import 'package:howtosolvequest/localizations/MainLocalizations.dart';
import 'package:howtosolvequest/models/AnswersModel.dart';
import 'package:howtosolvequest/models/LocaleModel.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

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

class SaveFile extends StatefulWidget {
  @override
  _SaveFileState createState() => _SaveFileState();
}

class _SaveFileState extends State<SaveFile> {
  _SaveFileState();
  var decoder = Excel.createExcel();

  var sheet = 'Result';
  saveFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();

    decoder
      ..updateCell(sheet, CellIndex.indexByString("A1"), "Here value of A1",
          fontColorHex: "#1AFF1A", verticalAlign: VerticalAlign.Top)
      ..updateCell(
          sheet,
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
          "Here value of C1",
          wrap: TextWrapping.WrapText)
      ..updateCell(sheet, CellIndex.indexByString("A2"), "Here value of A2",
          backgroundColorHex: "#1AFF1A")
      ..updateCell(sheet, CellIndex.indexByString("E5"), "Here value of E5",
          horizontalAlign: HorizontalAlign.Right);

    // Save the file

    decoder.encode().then((onValue) {
      File(join(directory.path, '/result.xlsx'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: (){
          saveFile();
        }, child: Text(MainLocalizations.of(context).save));
  }
}
