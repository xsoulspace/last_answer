import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/localizations/MainLocalizations.dart';
import 'package:lastanswer/models/LocaleModel.dart';
import 'package:lastanswer/models/PagesModel.dart';
import 'package:lastanswer/screens/AppPages.dart';
import 'package:lastanswer/screens/MenuDrawer.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({required double appBarHeight})
      : preferredSize = Size.fromHeight(kToolbarHeight + appBarHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  final Size preferredSize;
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late AnimationController _animationTitleController;
  late Animation<double> _animateTitle;

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

  getIsAnswers(PagesModel pagesModel) {
    return pagesModel.currentPage == AppPagesNumerated.AnswersScreen.index;
  }

  int _previousPageIndex = AppPagesNumerated.AskScreen.index;

  Widget currentTitle() {
    String title(PagesModel pagesModel) {
      final isPhilosophyPage =
          pagesModel.currentPage == AppPagesNumerated.Inspire.index;
      final isAnswersPage = getIsAnswers(pagesModel);

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
        // case 1:
        //   FocusScope.of(context).requestFocus(new FocusNode());
        //   return MainLocalizations.of(context).answers;
        // case 1:
        //   return MainLocalizations.of(context).philosophyAbstractTitle;
        // case 2:
        //   return MainLocalizations.of(context).aboutAbstractTitle;
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
            backgroundColor: isPhilosophyPage
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).primaryColor,
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  MenuDrawer.of(context)?.open();
                },
                icon: Icon(Icons.playlist_add_check),
              ),
            ),
            title: currentTitle(),
            elevation: isPhilosophyPage ? 0 : 4,
            centerTitle: true,
            actions: [],
          ));
    });
  }
}
