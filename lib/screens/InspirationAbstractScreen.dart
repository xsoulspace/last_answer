import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lastanswer/entities/LocaleTitle.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

class InspirationAbstract extends StatefulWidget {
  @override
  _InspirationAbstractState createState() => _InspirationAbstractState();
}

class _InspirationAbstractState extends State<InspirationAbstract> {
//   _launchURL() async {
//   const url = 'mailto:xsoulspace@gmail.com?subject=IIB_Last_Answer	';
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
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
                          return Text(
                            MainLocalizations.of(context).aboutAbstractTitle,
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
                            SizedBox(
                              width: 100,
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return Text(
                                  MainLocalizations.of(context)
                                      .aboutAbstractWhatFor,
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
                                      .aboutAbstractWhatForDescription,
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
                            SizedBox(
                              width: 100,
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return SelectableText(
                                  LocaleTitle('How?', 'Как?')
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
                                      .aboutAbstractHowDescription,
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
                            SizedBox(
                              width: 100,
                              child: Consumer<LocaleModel>(
                                  builder: (context, locale, child) {
                                return Text(
                                  MainLocalizations.of(context)
                                      .aboutAbstractIdeasImprovementsBugs,
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
                                      .aboutAbstractIdeasImprovementsBugsDescription,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
