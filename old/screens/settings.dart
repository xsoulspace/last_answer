import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/current_state_keys.dart';
import 'package:lastanswer/abstract/named_locale.dart';
import 'package:lastanswer/models/questions_model.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:lastanswer/utils/is_desktop.dart';
import 'package:lastanswer/widgets/restarter.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

const double appBarHeight = 48;

class _SettingsState extends State<Settings> {
  @override
  Widget build(final BuildContext context) {
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
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: SizedBox(
                      height: appBarHeight,
                      width: 56,
                      child: IconButton(
                        icon: const Icon(Icons.close),
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
                      color: Colors.transparent,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 600,
                          maxWidth: 400,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: GridView.count(
                            crossAxisCount: isDesktop ? 3 : 2,
                            padding: const EdgeInsets.all(20.0),
                            children: [
                              DarkModeSwitcher(),
                              LocaleSwitcher(),
                              About(),
                              Philosophy()
                            ],
                          ),
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
        {required final BuildContext context}) =>
    BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.secondary,
      ),
      shape: BoxShape.circle,
    );

class MenuTile extends StatelessWidget {
  final Widget iconButton;
  final Widget text;
  const MenuTile({
    required this.iconButton,
    required this.text,
  });
  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: getGridItemIconContainerDecoration(context: context),
            child: iconButton,
          ),
          const SizedBox(height: 4),
          text
        ],
      ),
    );
  }
}

class DarkModeSwitcher extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    final box = Hive.box<bool>(HiveBoxes.darkMode);
    final isDark = box.get(BoxDarkMode.isDark, defaultValue: false) ?? false;
    return MenuTile(
      iconButton: IconButton(
        onPressed: () async {
          await box.put(BoxDarkMode.isDark, !isDark);
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: isDark
              ? const Icon(Icons.wb_sunny_outlined)
              : const Icon(Icons.wb_sunny),
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
  Widget build(final BuildContext context) {
    final localeModel = Provider.of<LocaleModel>(context);
    return MenuTile(
      iconButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Consumer<LocaleModel>(
          builder: (final context, final locale, final child) {
            final textStyle = TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).textTheme.bodyText1?.color);
            return DropdownButton<NamedLocale>(
              value: locale.currentNamedLocale,
              style: textStyle,
              icon: Container(),
              isExpanded: true,
              selectedItemBuilder: (final context) {
                return namedLocales
                    .map(
                      (final namedLocale) => Container(
                        alignment: Alignment.center,
                        child: const Icon(Icons.translate),
                      ),
                    )
                    .toList();
              },
              underline: Container(),
              items: namedLocales.map<DropdownMenuItem<NamedLocale>>(
                (final namedLocale) {
                  return DropdownMenuItem<NamedLocale>(
                    value: namedLocale,
                    child: Text(
                      namedLocale.name,
                      style: textStyle,
                    ),
                  );
                },
              ).toList(),
              onChanged: (namedLocale) async {
                final isToChange = await showDialog<bool>(
                  context: context,
                  builder: (final context) {
                    return AlertDialog(
                      content: Text(
                          '${namedLocale?.name} ${AppLocalizations.of(context)?.languageWillBeChanged}'),
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
                  Restarter.restartApp(context);
                }
              },
            );
          },
        ),
      ),
      text: Text(
        '${AppLocalizations.of(context)?.language} - '
        '${namedLocalesMap[localeModel.locale.languageCode]?.name}',
        textAlign: TextAlign.center,
      ),
    );
  }
}

const Widget _itemDivider = Divider(
  height: 1,
);

Widget _questionBox({
  required final String? questionString,
}) =>
    SizedBox(
      width: 100,
      child: Consumer<LocaleModel>(
        builder: (final context, final locale, final child) {
          return Text(
            questionString ?? '',
          );
        },
      ),
    );

class About extends StatelessWidget {
  Widget itemCard({
    final String? questionString,
    required final String? answerString,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _questionBox(questionString: questionString),
          const Padding(
            padding: EdgeInsets.only(right: 5),
          ),
          Flexible(
            child: Consumer<LocaleModel>(
              builder: (final context, final locale, final child) {
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
  Widget build(final BuildContext context) {
    final localeModel = Provider.of<LocaleModel>(context);
    return MenuTile(
      iconButton: IconButton(
        onPressed: () {
          showAboutDialog(
            context: context,
            applicationName: AppLocalizations.of(context)?.lastAnswer ?? '',
            children: [
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    itemCard(
                        questionString: AppLocalizations.of(context)
                                ?.aboutAbstractWhatFor ??
                            '',
                        answerString: AppLocalizations.of(context)
                            ?.aboutAbstractWhatForDescription),
                    _itemDivider,
                    itemCard(
                        questionString: QuestionsModelConsts.titleHow
                            .getProp(localeModel.locale.languageCode),
                        answerString: AppLocalizations.of(context)
                            ?.aboutAbstractHowDescription),
                    _itemDivider,
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
        icon: const Icon(Icons.info),
      ),
      text: Text(
        AppLocalizations.of(context)?.about ?? '',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class Philosophy extends StatelessWidget {
  Widget itemCard({
    final String? questionString,
    required final String? answerString,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _questionBox(questionString: questionString),
          ),
          Flexible(
            child: Consumer<LocaleModel>(
              builder: (final context, final locale, final child) {
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
  Widget build(final BuildContext context) {
    final localeModel = Provider.of<LocaleModel>(context);
    return MenuTile(
      iconButton: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
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
                  child: Column(
                    children: <Widget>[
                      itemCard(
                          questionString: QuestionsModelConsts.titleWhat
                              .getProp(localeModel.locale.languageCode),
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractFiveWhyesWhat),
                      _itemDivider,
                      itemCard(
                          questionString: QuestionsModelConsts.titleWhy
                              .getProp(localeModel.locale.languageCode),
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractFiveWhyesWhy),
                      _itemDivider,
                      itemCard(
                          questionString: AppLocalizations.of(context)
                              ?.philosophyAbstractWhatElse,
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractPDSAWhat),
                      _itemDivider,
                      itemCard(
                          questionString: QuestionsModelConsts.titleWhy
                              .getProp(localeModel.locale.languageCode),
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractPDSAWhy),
                      _itemDivider,
                      itemCard(
                          questionString: AppLocalizations.of(context)
                              ?.philosophyAbstractWhatElse,
                          answerString: AppLocalizations.of(context)
                              ?.philosophyAbstractSixSigmaWhat),
                      _itemDivider,
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
        icon: const Icon(Icons.menu_book_rounded),
      ),
      text: Text(
        AppLocalizations.of(context)?.philosophyInspirationTitle ?? '',
        textAlign: TextAlign.center,
      ),
    );
  }
}
