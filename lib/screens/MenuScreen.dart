// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
// import 'package:lastanswer/components/htmlSaveFileComponent.dart';
import 'package:lastanswer/entities/Answer.dart';
import 'package:lastanswer/entities/NamedLocale.dart';
import 'package:lastanswer/models/PagesModel.dart';
import 'package:lastanswer/screens/ScaffoldAppBar.dart';
// import 'package:lastanswer/entities/Answer.dart';
import 'package:share/share.dart';

// import 'package:lastanswer/components/htmlSaveFileComponent.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/models/AnswersModel.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LocaleModel localeModel = Provider.of<LocaleModel>(context);
    PagesModel pagesModel = Provider.of<PagesModel>(context);

    cancelButton() {
      return FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(MainLocalizations.of(context).newQuestCancel),
      );
    }

    startButton() {
      return FlatButton(
        onPressed: () async {
          AnswersModel model =
              Provider.of<AnswersModel>(context, listen: false);
          await model.clearAll();
          pagesModel.pageController.animateToPage(
              AppPagesNumerated.AskScreen.index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutCirc);
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
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
                    return AlertDialog(
                      actions: [cancelButton(), startButton()],
                      title: Text(MainLocalizations.of(context).newQuest),
                      content: Text(MainLocalizations.of(context).newQuestDesc),
                    );
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
        Container(
          margin: EdgeInsets.only(bottom: 30),
          child: Center(
            child: IconButton(
              onPressed: () {
                pagesModel.pageController.animateToPage(
                    AppPagesNumerated.AskScreen.index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutCirc);
                Navigator.pop(context);
              },
              icon: Icon(Icons.home),
              tooltip: 'home',
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            buttonStart(),
            SaveFile(),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 25, top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Consumer<LocaleModel>(builder: (context, locale, child) {
                return DropdownButton<NamedLocale>(
                  value: locale.currentNamedLocale,
                  items: LocaleModelConsts.namedLocales
                      .map<DropdownMenuItem<NamedLocale>>((namedLocale) {
                    return DropdownMenuItem<NamedLocale>(
                      value: namedLocale,
                      child: Text(namedLocale.name),
                    );
                  }).toList(),
                  onChanged: (NamedLocale namedLocale) async {
                    await localeModel.switchLang(namedLocale.locale);
                  },
                );
              })
            ],
          ),
        ),
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
      // FIXME: code to think
      // await SimplePermissions.requestPermission(
      //     Permission.WriteExternalStorage);
      // bool checkPermission = await SimplePermissions.checkPermission(
      //     Permission.WriteExternalStorage);
      // if (checkPermission) {
      //store file in documents folder

      // String dir =
      //     (await getExternalStorageDirectory()).absolute.path + "/documents";
      // File f = new File("./filename.csv");
      // var sink = f.openWrite();
      // sink.write('FILE ACCESSED ${new DateTime.now()}\n');
      // sink.close();

      /** working code */
      // final h = HtmlSaveFileComponent(context);
      // await h.saveInWeb();
    }

    share(BuildContext context) {
      final RenderBox box = context.findRenderObject();
      AnswersModel answers = Provider.of<AnswersModel>(context);

      List<Answer> answersList = answers.answersList;
      LocaleModel locale = Provider.of<LocaleModel>(context);
      final lang = locale.current;
      final String answersAndQuestionsSentence = answersList.fold(
          '',
          (previousValue, element) =>
              '$previousValue\n${element.question.title.getProp(lang)} ${element.title}; ');
      Share.share(answersAndQuestionsSentence,
          subject: 'HTSTQ: ${answersList.first}',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }

    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () async {
            kIsWeb ? await saveAsWeb() : share(context);
          },
          icon: Icon(Icons.share),
        ),
      ],
    );
  }
}
