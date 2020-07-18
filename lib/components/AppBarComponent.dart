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
  AnimationController _animationTitleController;
  Animation<double> _animateTitle;
  @override
  initState() {
    super.initState();
    _animationTitleController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1400));

    _animateTitle =
        Tween(begin: 0.0, end: 1.0).animate(_animationTitleController);
  }

  @override
  dispose() {
    _animationTitleController.dispose();
    super.dispose();
  }

  getIsPhilophyAndInspire(PagesModel pagesModel) {
    return pagesModel.currentPage == AppPagesNumerated.Philosophy.index ||
        pagesModel.currentPage == AppPagesNumerated.Inspire.index;
  }

  int _previousPageIndex;
  Widget currentTitle() {
    String title(PagesModel pagesModel) {
      final isPhilosophyPage =
          pagesModel.currentPage == AppPagesNumerated.Inspire.index;
      final isAnswersPage =
          pagesModel.currentPage == AppPagesNumerated.AnswersScreen.index;

      final isToToogleAnimation = (isPhilosophyPage &&
              _previousPageIndex == AppPagesNumerated.AnswersScreen.index) ||
          (isAnswersPage &&
              _previousPageIndex == AppPagesNumerated.Inspire.index);

      if (isToToogleAnimation) {
        _animationTitleController.reset();
        _animationTitleController.forward();
      }

      _previousPageIndex = pagesModel.currentPage;

      switch (pagesModel.currentPage) {
        case 0:
          return MainLocalizations.of(context).lastAnswer;
        case 1:
          FocusScope.of(context).requestFocus(new FocusNode());
          return MainLocalizations.of(context).answers;
        case 2:
          return MainLocalizations.of(context).philosophyAndInspirationTitle;
        case 3:
          return MainLocalizations.of(context).philosophyAndInspirationTitle;
        // return MainLocalizations.of(context).lastAnswer;
      }
      return '';
    }

    double getFontSize(PagesModel pagesModel) {
      switch (pagesModel.currentPage) {
        case 0:
          return 24;
        case 1:
          return 24;
        case 2:
          return 17;
        case 3:
          return 17;
        // return MainLocalizations.of(context).lastAnswer;
      }
      return 24;
    }

    return Consumer2<LocaleModel, PagesModel>(
        builder: (context, locale, pagesModel, child) {
      return Text(
        title(pagesModel),
        style: TextStyle(
          fontSize: getFontSize(pagesModel),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _animationTitleController.forward();
    return Consumer<PagesModel>(builder: (context, pagesModel, child) {
      final isPhilosophyPage = getIsPhilophyAndInspire(pagesModel);
      return FadeTransition(
          opacity: _animateTitle,
          child: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/menu');
              },
              icon: Icon(Icons.playlist_add_check),
            ),
            backgroundColor: isPhilosophyPage
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).primaryColor,
            title: currentTitle(),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  pagesModel.pageController.animateToPage(
                      AppPagesNumerated.AnswersScreen.index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOutCirc);
                },
                icon: Icon(Icons.import_contacts),
              ),
            ],
          ));
    });

    // PreferredSize(
    //     preferredSize: Size.fromHeight(_height), // Size(_height, _height),
    //     child: Consumer<PagesModel>(builder: (context, pagesModel, child) {
    //       final isPhilosophyPage = getIsPhilophyAndInspire(pagesModel);
    //       return AnimatedContainer(
    //           color: isPhilosophyPage
    //               ? Theme.of(context).scaffoldBackgroundColor
    //               : Theme.of(context).primaryColor,
    //           duration: Duration(seconds: 1),
    //           curve: Curves.easeOutBack,
    //           height: _height,
    //           child: LayoutBuilder(
    //               builder: (BuildContext context, BoxConstraints constraints) {
    //             return Stack(
    //               children: <Widget>[
    //                 Positioned(
    //                   left: 5,
    //                   top: kIsWeb ? 10 : 30,
    //                   child: IconButton(
    //                     onPressed: () {
    //                       Navigator.pushNamed(context, '/menu');
    //                     },
    //                     icon: Icon(Icons.playlist_add_check),
    //                     tooltip: 'complete',
    //                   ),
    //                 ),
    //                 Positioned(
    //                   child: FadeTransition(
    //                     opacity: _animateTitle,
    //                     child: currentTitle(),
    //                   ),
    //                   top: 40,
    //                   left: 70,
    //                 ),
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.end,
    //                   children: [
    //                     Padding(
    //                       padding: EdgeInsets.only(top: kIsWeb ? 10 : 30),
    //                       child: IconButton(
    //                         onPressed: () {
    //                           pagesModel.pageController.animateToPage(
    //                               AppPagesNumerated.AnswersScreen.index,
    //                               duration: Duration(milliseconds: 300),
    //                               curve: Curves.easeOutCirc);
    //                         },
    //                         icon: Icon(Icons.import_contacts),
    //                       ),
    //                     )
    //                   ],
    //                 )
    //               ],
    //             );
    //           }));
    //     }));
  }
}
