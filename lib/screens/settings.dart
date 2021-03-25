import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/HiveBoxes.dart';
import 'package:lastanswer/abstract/LocaleTitle.dart';
import 'package:lastanswer/abstract/NamedLocale.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:lastanswer/utils/is_desktop.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

const double AppBarHeight = 48;

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
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
                      height: AppBarHeight,
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
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'appBarBackground',
                    child: Container(
                      height: size.height - AppBarHeight,
                      color: Theme.of(context).canvasColor,
                      child: Material(
                        child: GridView.count(
                          crossAxisCount: isDesktop() ? 3 : 2,
                          childAspectRatio: 1,
                          padding: EdgeInsets.all(20.0),
                          children: [
                            DarkModeSwitcher(),
                            // FIXME: restore locale switcher
                            // LocaleSwitcher(),
                            About(),
                            Philosophy()
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Decoration getGridItemIconContainerDecoration(
        {required BuildContext context}) =>
    BoxDecoration(
      border: Border.all(color: Theme.of(context).accentColor, width: 1),
      shape: BoxShape.circle,
    );

class MenuTile extends StatelessWidget {
  final Widget iconButton;
  final Widget text;
  MenuTile({required this.iconButton, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      Container(
          height: 60,
          width: 60,
          decoration: getGridItemIconContainerDecoration(context: context),
          child: iconButton),
      SizedBox(
        height: 4,
      ),
      text
    ]));
  }
}

class DarkModeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box<bool>(HiveBoxes.darkMode);
    var isDark = box.get(BoxDarkMode.isDark, defaultValue: false) ?? false;
    return MenuTile(
        iconButton: IconButton(
          onPressed: () async {
            await box.put(BoxDarkMode.isDark, !isDark);
          },
          icon: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child:
                isDark ? Icon(Icons.wb_sunny_outlined) : Icon(Icons.wb_sunny),
          ),
        ),
        text: Text(
          'Dark mode',
          textAlign: TextAlign.center,
        ));
  }
}

class LocaleSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);
    return MenuTile(
        iconButton: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Consumer<LocaleModel>(builder: (context, locale, child) {
            final textStyle = TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).textTheme.bodyText1?.color);
            return DropdownButton<NamedLocale>(
              value: locale.currentNamedLocale,
              style: textStyle,
              icon: Container(),
              isExpanded: true,
              selectedItemBuilder: (context) {
                return LocaleModelConsts.namedLocales
                    .map((namedLocale) => Container(
                          alignment: Alignment.center,
                          child: Icon(Icons.translate),
                        ))
                    .toList();
              },
              underline: Container(),
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
          }),
        ),
        text: Text(
          'Language',
          textAlign: TextAlign.center,
        ));
  }
}

class About extends StatelessWidget {
  Widget itemCard(
      {required String? questionString, required String? answerString}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Consumer<LocaleModel>(builder: (context, locale, child) {
                return Text(questionString ?? '');
              }),
            ),
            Padding(
              padding: EdgeInsets.only(right: 5),
            ),
            Flexible(
              child: Consumer<LocaleModel>(builder: (context, locale, child) {
                return SelectableText(
                  answerString ?? '',
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);
    return MenuTile(
        iconButton: IconButton(
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: 'Last Answer',
                  children: [
                    SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: <Widget>[
                            itemCard(
                                questionString: AppLocalizations.of(context)
                                    ?.aboutAbstractWhatFor,
                                answerString: AppLocalizations.of(context)
                                    ?.aboutAbstractWhatForDescription),
                            itemCard(
                                questionString: LocaleTitle(
                                        en: 'How?', ru: 'Как?')
                                    .getProp(localeModel.locale.languageCode),
                                answerString: AppLocalizations.of(context)
                                    ?.aboutAbstractHowDescription),
                            itemCard(
                                questionString: AppLocalizations.of(context)
                                    ?.aboutAbstractIdeasImprovementsBugs,
                                answerString: AppLocalizations.of(context)
                                    ?.aboutAbstractIdeasImprovementsBugsDescription),
                          ],
                        ))
                  ]);
            },
            icon: Icon(Icons.info)),
        text: Text(
          'About',
          textAlign: TextAlign.center,
        ));
  }
}

class Philosophy extends StatelessWidget {
  Widget itemCard(
      {required String? questionString, required String? answerString}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5),
            ),
            SizedBox(
              width: 80,
              child:
                  Consumer<LocaleModel>(builder: (context, localeModel, child) {
                return SelectableText(
                  questionString ?? '',
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.only(right: 5),
            ),
            Flexible(
              child: Consumer<LocaleModel>(builder: (context, locale, child) {
                return SelectableText(
                  answerString ?? '',
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  final whyQuestion = LocaleTitle(en: 'Why?', ru: 'Почему?');
  final whatQuestion = LocaleTitle(en: 'What?', ru: 'Что?');
  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);
    return MenuTile(
        iconButton: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(AppLocalizations.of(context)
                                ?.philosophyInspirationTitle ??
                            ''),
                        content: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: <Widget>[
                                itemCard(
                                    questionString: whatQuestion.getProp(
                                        localeModel.locale.languageCode),
                                    answerString: AppLocalizations.of(context)
                                        ?.philosophyAbstractFiveWhyesWhat),
                                itemCard(
                                    questionString: whyQuestion.getProp(
                                        localeModel.locale.languageCode),
                                    answerString: AppLocalizations.of(context)
                                        ?.philosophyAbstractFiveWhyesWhy),
                                itemCard(
                                    questionString: AppLocalizations.of(context)
                                        ?.philosophyAbstractWhatElse,
                                    answerString: AppLocalizations.of(context)
                                        ?.philosophyAbstractPDSAWhat),
                                itemCard(
                                    questionString: whyQuestion.getProp(
                                        localeModel.locale.languageCode),
                                    answerString: AppLocalizations.of(context)
                                        ?.philosophyAbstractPDSAWhy),
                                itemCard(
                                    questionString: AppLocalizations.of(context)
                                        ?.philosophyAbstractWhatElse,
                                    answerString: AppLocalizations.of(context)
                                        ?.philosophyAbstractSixSigmaWhat),
                                itemCard(
                                    questionString: whyQuestion.getProp(
                                        localeModel.locale.languageCode),
                                    answerString: AppLocalizations.of(context)
                                        ?.philosophyAbstractSixSigmaWhy),
                              ],
                            )));
                  });
            },
            icon: Icon(Icons.menu_book_rounded)),
        text: Text(
          AppLocalizations.of(context)?.philosophyInspirationTitle ?? '',
          textAlign: TextAlign.center,
        ));
  }
}
