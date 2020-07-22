import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/models/PagesModel.dart';
import 'package:lastanswer/screens/AnswersScreen.dart';
import 'package:lastanswer/screens/AskScreen.dart';
import 'package:lastanswer/screens/InspirationAbstractScreen.dart';
import 'package:lastanswer/screens/PhilosophyAbstractScreen.dart';
import 'package:provider/provider.dart';

class AppPages extends StatefulWidget {
  @override
  _AppPagesState createState() => _AppPagesState();
}

enum AppPagesNumerated {
  AskScreen,
  AnswersScreen,
  Inspire,
  Philosophy,
}

class _AppPagesState extends State<AppPages> {
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PagesModel pagesModel = Provider.of<PagesModel>(context);
    pagesModel.setPageController(_pageController);

    return PageView(
      controller: _pageController,
      onPageChanged: (pageNumber) => pagesModel.setPageInt(pageNumber),
      children: [
        AskScreen(),
        AnswersScreen(),
        PhilosophyAbstract(),
        InspirationAbstract(),
      ],
    );
  }
}
