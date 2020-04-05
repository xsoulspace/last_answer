import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvequest/components/CustomDialogComponent.dart';
import 'package:howtosolvequest/entities/Answer.dart';
import 'package:howtosolvequest/localizations/MainLocalizations.dart';
import 'package:howtosolvequest/models/AnswersModel.dart';
import 'package:howtosolvequest/models/LocaleModel.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

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

  @override
  Widget build(BuildContext context) {
    saveFile() async {
      var decoder = Excel.createExcel();
      var sheet = 'Sheet1';
      int i = 1;
      var answers = Provider.of<AnswersModel>(context);
      List answ = answers.answersList;
      for (Answer answer in answ) {
        String cellAddressA = 'A${i.toString()}';
        String cellAddressB = 'B${i.toString()}';
        String cellAddressC = 'C${i.toString()}';

        decoder
          ..updateCell(sheet, CellIndex.indexByString(cellAddressA),
              answer.question.title.ru)
          ..updateCell(sheet, CellIndex.indexByString(cellAddressB),
              answer.question.title.en)
          ..updateCell(
              sheet, CellIndex.indexByString(cellAddressC), answer.title,
              verticalAlign: VerticalAlign.Top);

        i++;
      }

      final blob = html.Blob([await decoder.encode()]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'some_name.xlsx';
      html.document.body.children.add(anchor);

      // download
      anchor.click();

      // cleanup
      html.document.body.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      // decoder.encode().then((onValue) {
      //   File(join(directory.path, '/result.xlsx'))
      //     ..createSync(recursive: true)
      //     ..writeAsBytesSync(onValue);
      // });
      // var path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
      // var file = new File(join(path,'file.txt'));
      // var sink = file.openWrite();
      // sink.write('FILE ACCESSED ${new DateTime.now()}\n');

      // // Close the IOSink to free system resources.
      // sink.close();
    }

    return FlatButton(
        onPressed: () {
          saveFile();
        },
        child: Text(MainLocalizations.of(context).save));
  }
}
