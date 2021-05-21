import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';
import 'package:lastanswer/abstract/named_locale.dart';
import 'package:lastanswer/main.dart';
import 'package:lastanswer/models/questions_model.dart';
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
      backgroundColor: Colors.transparent,
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
                      color: Colors.transparent,
                      child: Material(
                        color: Colors.transparent,
                        child: GridView.count(
                          crossAxisCount: isDesktop() ? 3 : 2,
                          childAspectRatio: 1,
                          padding: EdgeInsets.all(20.0),
                          children: [
                            DarkModeSwitcher(),
                            LocaleSwitcher(),
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
      child: Column(
        children: [
          Container(
              height: 60,
              width: 60,
              decoration: getGridItemIconContainerDecoration(context: context),
              child: iconButton),
          SizedBox(
            height: 4,
          ),
          text
        ],
      ),
    );
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
          child: isDark ? Icon(Icons.wb_sunny_outlined) : Icon(Icons.wb_sunny),
        ),
      ),
      text: Text(
        AppLocalizations.of(context)?.darkMode ?? '',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class LocaleSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localeModel = Provider.of<LocaleModel>(context);
    return MenuTile(
      iconButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Consumer<LocaleModel>(
          builder: (context, locale, child) {
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
                  .map<DropdownMenuItem<NamedLocale>>(
                (namedLocale) {
                  return DropdownMenuItem<NamedLocale>(
                    value: namedLocale,
                    child: Text(
                      namedLocale.name,
                      style: textStyle,
                    ),
                  );
                },
              ).toList(),
              onChanged: (NamedLocale? namedLocale) async {
                final isToChange = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                          "${namedLocale?.name} ${AppLocalizations.of(context)?.languageWillBeChanged}"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child:
                              Text(AppLocalizations.of(context)?.cancel ?? ''),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child:
                                Text(AppLocalizations.of(context)?.yes ?? ''))
                      ],
                    );
                  },
                );
                if (isToChange == true) {
                  await localeModel.switchLang(namedLocale?.locale);
                  RestartWidget.restartApp(context);
                }
              },
            );
          },
        ),
      ),
      text: Text(
        '${AppLocalizations.of(context)?.language} - '
        '${LocaleModelConsts.namedLocalesMap[localeModel.locale.languageCode]?.name}',
        textAlign: TextAlign.center,
      ),
    );
  }
}

const Widget _ItemDivider = Divider(
  height: 1,
);

Widget Function({
  String? questionString,
}) _questionBox = ({
  questionCallback,
  questionString,
}) =>
    SizedBox(
      width: 100,
      child: Consumer<LocaleModel>(
        builder: (context, locale, child) {
          return Text(
            questionString ?? '',
          );
        },
      ),
    );

class About extends StatelessWidget {
  Widget itemCard({String? questionString, required String? answerString}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          _questionBox(questionString: questionString),
          Padding(
            padding: EdgeInsets.only(right: 5),
          ),
          Flexible(
            child: Consumer<LocaleModel>(
              builder: (context, locale, child) {
                return SelectableText(
                  answerString ?? '',
                );
              },
            ),
          ),
        ],
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
              applicationName: AppLocalizations.of(context)?.lastAnswer ?? '',
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      itemCard(
                          questionString: AppLocalizations.of(context)
                                  ?.aboutAbstractWhatFor ??
                              '',
                          answerString: AppLocalizations.of(context)
                              ?.aboutAbstractWhatForDescription),
                      _ItemDivider,
                      itemCard(
                          questionString: QuestionsModelConsts.titleHow
                              .getProp(localeModel.locale.languageCode),
                          answerString: AppLocalizations.of(context)
                              ?.aboutAbstractHowDescription),
                      _ItemDivider,
                      itemCard(
                          questionString: AppLocalizations.of(context)
                              ?.aboutAbstractIdeasImprovementsBugs,
                          answerString: AppLocalizations.of(context)
                              ?.aboutAbstractIdeasImprovementsBugsDescription),
                    ],
                  ),
                )
              ],
            );
          },
          icon: Icon(Icons.info)),
      text: Text(
        AppLocalizations.of(context)?.about ?? '',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class Philosophy extends StatelessWidget {
  Widget itemCard({String? questionString, required String? answerString}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5),
          ),
          _questionBox(questionString: questionString),
          Padding(
            padding: EdgeInsets.only(right: 5),
          ),
          Flexible(
            child: Consumer<LocaleModel>(
              builder: (context, locale, child) {
                return SelectableText(
                  answerString ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
                title: Text(
                    AppLocalizations.of(context)?.philosophyInspirationTitle ??
                        ''),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)?.close ?? '',
                      ))
                ],
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      itemCard(
                          questionString: QuestionsModelConsts.titleWhat
                              .getProp(localeModel.locale.languageCode),
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractFiveWhyesWhat),
                      _ItemDivider,
                      itemCard(
                          questionString: QuestionsModelConsts.titleWhy
                              .getProp(localeModel.locale.languageCode),
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractFiveWhyesWhy),
                      _ItemDivider,
                      itemCard(
                          questionString: AppLocalizations.of(context)
                              ?.philosophyAbstractWhatElse,
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractPDSAWhat),
                      _ItemDivider,
                      itemCard(
                          questionString: QuestionsModelConsts.titleWhy
                              .getProp(localeModel.locale.languageCode),
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractPDSAWhy),
                      _ItemDivider,
                      itemCard(
                          questionString: AppLocalizations.of(context)
                              ?.philosophyAbstractWhatElse,
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractSixSigmaWhat),
                      _ItemDivider,
                      itemCard(
                        questionString: QuestionsModelConsts.titleWhy
                            .getProp(localeModel.locale.languageCode),
                        answerString: AppLocalizations.of(context)
                            ?.philosophyAbstractSixSigmaWhy,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        icon: Icon(Icons.menu_book_rounded),
      ),
      text: Text(
        AppLocalizations.of(context)?.philosophyInspirationTitle ?? '',
        textAlign: TextAlign.center,
      ),
    );
  }
}
