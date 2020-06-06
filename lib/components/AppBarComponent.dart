import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:howtosolvethequest/models/PagesModel.dart';
import 'package:howtosolvethequest/screens/ScaffoldAppBar.dart';
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

class _AppBarComponentState extends State<AppBarComponent>
    with TickerProviderStateMixin {
  final double _height = 200.0;

  AnimationController _animationTitleController;
  Animation<double> _animateTitle;
  @override
  initState() {
    super.initState();
    _animationTitleController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3000));
    _animateTitle =
        Tween(begin: 0.0, end: 1.0).animate(_animationTitleController);
  }

  @override
  dispose() {
    _animationTitleController.dispose();
    super.dispose();
  }

  Widget currentTitle() {
    String title(PagesModel pagesModel) {
      if (_animationTitleController.isAnimating) {
        _animationTitleController.reset();
        _animationTitleController.repeat(reverse: false, min: 0, max: 1);
      }
      switch (pagesModel.currentPage) {
        case 0:
          return MainLocalizations.of(context).lastAnswer;
        case 1:
          return MainLocalizations.of(context).answers;
        case 2:
          return 'Philosophy';
        // return MainLocalizations.of(context).lastAnswer;
      }
      return '';
    }

    return Consumer2<LocaleModel, PagesModel>(
        builder: (context, locale, pagesModel, child) {
      return Text(
        title(pagesModel),
        style: TextStyle(
            fontSize: 24,
            shadows: [Shadow(color: Colors.black54, blurRadius: 10.0)]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _animationTitleController.forward();

    return PreferredSize(
        preferredSize: Size(_height, _height),
        child: Consumer<PagesModel>(builder: (context, pagesModel, child) {
          final isPhilosophyPage =
              pagesModel.currentPage == AppPagesNumerated.Philosophy.index;
          return AnimatedContainer(
              color: isPhilosophyPage
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).primaryColor,
              duration: Duration(seconds: 1),
              curve: Curves.easeOutBack,
              height: _height,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                double titleXPosition() {
                  if (constraints.maxWidth > 600) {
                    return 250;
                  } else {
                    return 150;
                  }
                }

                return Stack(
                  children: <Widget>[
                    Positioned(
                      child: FadeTransition(
                        opacity: _animateTitle,
                        child: currentTitle(),
                      ),
                      top: 40,
                      left: titleXPosition(),
                    ),
                  ],
                );
              }));
        }));
  }
}
