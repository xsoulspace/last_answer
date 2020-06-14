// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:howtosolvethequest/components/CustomDialogComponent.dart';
import 'package:howtosolvethequest/entities/Answer.dart';
import 'package:howtosolvethequest/models/PagesModel.dart';
import 'package:howtosolvethequest/screens/ScaffoldAppBar.dart';
// import 'package:howtosolvethequest/entities/Answer.dart';
import 'package:share/share.dart';

// import 'package:howtosolvethequest/components/htmlSaveFileComponent.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);
    PagesModel pagesModel = Provider.of<PagesModel>(context);

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
        onPressed: () async {
          var model = Provider.of<AnswersModel>(context, listen: false);
          await model.clearAll();
          pagesModel.pageController.animateToPage(
              AppPagesNumerated.AskScreen.index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutCirc);
          Navigator.pop(context);
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
        Divider(
          height: 40,
          color: Theme.of(context).primaryColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                onPressed: () async {
                  await localeModel.switchLang(Locale('ru', 'RU'));
                },
                child: Text("Rus")),
            FlatButton(
                onPressed: () async {
                  await localeModel.switchLang(Locale('en', 'EN'));
                },
                child: Text("Eng")),
          ],
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
    // saveAsWeb() async {
    //   // FIXME: code to think
    //   // await SimplePermissions.requestPermission(
    //   //     Permission.WriteExternalStorage);
    //   // bool checkPermission = await SimplePermissions.checkPermission(
    //   //     Permission.WriteExternalStorage);
    //   // if (checkPermission) {
    //   //store file in documents folder

    //   // String dir =
    //   //     (await getExternalStorageDirectory()).absolute.path + "/documents";
    //   // File f = new File("./filename.csv");
    //   // var sink = f.openWrite();
    //   // sink.write('FILE ACCESSED ${new DateTime.now()}\n');
    //   // sink.close();

    //   /** working code */
    //   // final h = HtmlSaveFileComponent(context);
    //   // await h.saveInWeb();

    // }
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
          onPressed: () {
            share(context);
          },
          icon: Icon(Icons.share),
        ),
      ],
    );
  }
}
