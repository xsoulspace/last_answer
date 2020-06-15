import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:howtosolvethequest/entities/LocaleTitle.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:provider/provider.dart';

class PhilosophyAbstract extends StatefulWidget {
  @override
  _PhilosophyAbstractState createState() => _PhilosophyAbstractState();
}

class _PhilosophyAbstractState extends State<PhilosophyAbstract> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractTitle,
                                );
                              }),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 30),
                    ),
                    Card(
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
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  LocaleTitle('What?', 'Что?')
                                      .getProp(locale.current),
                                );
                              }),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                            ),
                            Flexible(
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractFiveWhyesWhat,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  LocaleTitle('Why?', 'Почему?')
                                      .getProp(locale.current),
                                );
                              }),
                            ),
                            Flexible(
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractFiveWhyesWhy,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return Text(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractWhatElse,
                                );
                              }),
                            ),
                            Flexible(
                                child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractPDSAWhat,
                                );
                              }),),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  LocaleTitle('Why?', 'Почему?')
                                      .getProp(locale.current),
                                );
                              }),
                            ),
                            Flexible(
                                child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractPDSAWhy,
                                );
                              }),),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return Text(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractWhatElse,
                                );
                              }),
                            ),
                            Flexible(
                                child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractSixSigmaWhat,
                                );
                              }),),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  LocaleTitle('Why?', 'Почему?')
                                      .getProp(locale.current),
                                );
                              }),
                            ),
                            Flexible(
                                child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  MainLocalizations.of(context)
                                      .philosophyAbstractSixSigmaWhy,
                                );
                              }),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
