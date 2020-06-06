import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:howtosolvethequest/models/PagesModel.dart';
import 'package:provider/provider.dart';

class AppBarComponent extends StatefulWidget implements PreferredSizeWidget {
  AppBarComponent({
    this.bottom,
  }) : preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0));

  @override
  _AppBarComponentState createState() => _AppBarComponentState();
  final PreferredSizeWidget bottom;

  @override
  final Size preferredSize;
}

class _AppBarComponentState extends State<AppBarComponent> {
  final double _height = 200.0;

  Widget currentTitle() {
    PagesModel pagesModel = Provider.of<PagesModel>(context);
    String title() {
      switch (pagesModel.currentPage) {
        case 1:
          return MainLocalizations.of(context).lastAnswer;
        case 2:
          return MainLocalizations.of(context).answers;
        case 3:
          return '';
        // return MainLocalizations.of(context).lastAnswer;
      }
      return '';
    }

    return Consumer<LocaleModel>(builder: (context, locale, child) {
      return Text(
        title(),
        style: TextStyle(
            fontSize: 24,
            shadows: [Shadow(color: Colors.black54, blurRadius: 10.0)]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(_height, _height),
      child: AnimatedContainer(
          color: Theme.of(context).primaryColor,
          duration: Duration(seconds: 1),
          height: _height,
          child: LayoutBuilder(builder: (context, constraint) {
            return Stack(
              children: <Widget>[
                Center(child: currentTitle()),
              ],
            );
          })),
    );
  }
}
