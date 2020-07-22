import 'package:flutter/cupertino.dart';
import 'package:lastanswer/screens/AppPages.dart';

class PagesModel extends ChangeNotifier {
  int _currentPage = AppPagesNumerated.AskScreen.index;
  PageController _pageController;
  void setPage(AppPagesNumerated page) async {
    _currentPage = page.index;
    notifyListeners();
  }

  void setPageInt(int page) async {
    _currentPage = page;
    notifyListeners();
  }

  int get currentPage => _currentPage;
  PageController get pageController => _pageController;
  void setPageController(PageController controller) {
    _pageController = controller;
  }
}
