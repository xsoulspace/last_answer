import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/screens/InspirationAbstractScreen.dart';
import 'package:lastanswer/screens/PhilosophyAbstractScreen.dart';

enum AppPagesNumerated {
  Inspire,
  Philosophy,
}

class HelpPages extends StatefulWidget {
  @override
  _HelpPagesState createState() => _HelpPagesState();
}

class _HelpPagesState extends State<HelpPages> {
  late PageController _pageController;
  _hideKeyboard() {
    var currentFocus = FocusScope.of(context);
    var focusedChild = currentFocus.focusedChild;
    if (!currentFocus.hasPrimaryFocus && focusedChild != null) {
      focusedChild.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController()..addListener(() => _hideKeyboard());
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(() => _hideKeyboard())
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (pageNumber) {},
      children: [
        PhilosophyAbstract(),
        InspirationAbstract(),
      ],
    );
  }
}
