// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
// import 'package:lastanswer/components/htmlSaveFileComponent.dart';
import 'package:lastanswer/entities/Answer.dart';
import 'package:lastanswer/entities/NamedLocale.dart';
// import 'package:lastanswer/components/htmlSaveFileComponent.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/models/AnswersModel.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:lastanswer/models/PagesModel.dart';
import 'package:lastanswer/screens/AppPages.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';
import 'package:provider/provider.dart';
// import 'package:lastanswer/entities/Answer.dart';
import 'package:share/share.dart';

class MenuScreen extends StatelessWidget {
  _closeDrawer(BuildContext context) {
    MenuDrawer.of(context)?.close();
  }

  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);
    var pagesModel = Provider.of<PagesModel>(context);
    var currentFocus = FocusScope.of(context);
    var focusedChild = currentFocus.focusedChild;
    if (!currentFocus.hasPrimaryFocus && focusedChild != null) {
      focusedChild.unfocus();
    }
    cancelButton() {
      return FlatButton(
        onPressed: () {
          Navigator?.of(context).pop();
        },
        child: Text(MainLocalizations.of(context).newQuestCancel),
      );
    }

    _gotoPage(int page) {
      pagesModel.pageController?.animateToPage(page,
          duration: Duration(milliseconds: 300), curve: Curves.easeOutCirc);
    }

    _dismissAndGoToAskScreen() {
      _closeDrawer(context);
      _gotoPage(AppPagesNumerated.AskScreen.index);
    }

    startButton() {
      return FlatButton(
        onPressed: () async {
          AnswersModel answersModel =
              Provider.of<AnswersModel>(context, listen: false);

          await answersModel.clearAll();
          Navigator?.of(context).pop();
          _dismissAndGoToAskScreen();
        },
        child: Text(MainLocalizations.of(context).newQuestStart),
        color: Theme.of(context).buttonTheme.colorScheme?.error,
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

    final EdgeInsetsGeometry centerRowEdge =
        EdgeInsets.fromLTRB(28, 30, 28, 30);
    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                _gotoPage(AppPagesNumerated.Philosophy.index);

                _closeDrawer(context);
              },
              child: Text(MainLocalizations.of(context).aboutAbstractTitle)),
          FlatButton(
              onPressed: () {
                _gotoPage(AppPagesNumerated.Inspire.index);

                _closeDrawer(context);
              },
              child:
                  Text(MainLocalizations.of(context).philosophyAbstractTitle)),
          // Padding(
          //   padding: EdgeInsets.only(left: 25, bottom: 30),
          //   child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Consumer<LocaleModel>(builder: (context, locale, child) {
                final textStyle =
                    TextStyle(fontSize: 14.0, color: Colors.white);
                return DropdownButton<NamedLocale>(
                  value: locale.currentNamedLocale,
                  style: textStyle,
                  items: LocaleModelConsts.namedLocales
                      .map<DropdownMenuItem<NamedLocale>>((namedLocale) {
                    return DropdownMenuItem<NamedLocale>(
                      value: namedLocale,
                      child: Text(
                        namedLocale.name,
                        style: textStyle,
                      ),
                    );
                  }).toList(),
                  onChanged: (NamedLocale? namedLocale) async {
                    await localeModel.switchLang(namedLocale?.locale);
                  },
                );
              })
            ],
          ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: centerRowEdge,
                child: IconButton(
                  onPressed: () {
                    _closeDrawer(context);
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ),
              Padding(
                padding: centerRowEdge,
                child: buttonStart(),
              ),
              Padding(
                padding: centerRowEdge,
                child: SaveFile(),
              )
            ],
          ),
          Center(
            child: IconButton(
              onPressed: () {
                _dismissAndGoToAskScreen();
              },
              icon: Icon(Icons.home),
              tooltip: 'home',
            ),
          ),
        ],
      ),
    );
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

    share(BuildContext context) async {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      AnswersModel answersModel =
          Provider.of<AnswersModel>(context, listen: false);

      List<Answer> answersList = answersModel.answersList;

      LocaleModel locale = Provider.of<LocaleModel>(context, listen: false);
      final lang = locale.current;
      final String answersAndQuestionsSentence = answersList.fold(
          '',
          (previousValue, element) =>
              '$previousValue\n${element.question.title.getProp(lang)} ${element.title} ');
      Share.share(answersAndQuestionsSentence,
          subject: '${answersList.first.title}',
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
