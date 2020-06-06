import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvethequest/components/AppBarComponent.dart';
import 'package:howtosolvethequest/localizations/MainLocalizations.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:howtosolvethequest/models/PagesModel.dart';
import 'package:howtosolvethequest/screens/AnswersScreen.dart';
import 'package:howtosolvethequest/screens/AskScreen.dart';
import 'package:howtosolvethequest/screens/PhilosophyScreen.dart';
import 'package:provider/provider.dart';

class ScaffoldAppBar extends StatelessWidget {
  // title: Text(MainLocalizations.of(context).answers),
  Widget oldBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, '/menu');
        },
        icon: Icon(Icons.playlist_add_check),
        tooltip: 'complete',
      ),
      centerTitle: true,
      title: Consumer<LocaleModel>(builder: (context, locale, child) {
        return Text((MainLocalizations.of(context).lastAnswer));
      }),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/philosophy');
          },
          icon: Icon(Icons.help_outline),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/answers');
          },
          icon: Icon(Icons.import_contacts),
        ),

        // RaisedButton(
        //   onPressed: () {
        //     Navigator.pushNamed(context, '/answers');
        //   },
        //   child: Consumer<LocaleModel>(builder: (context, locale, child) {
        //     return Text((MainLocalizations.of(context).answers));
        //   }),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(),
      body: AppPages(),
    );
  }
}

class AppPages extends StatefulWidget {
  @override
  _AppPagesState createState() => _AppPagesState();
}

enum AppPagesNumerated {
  AskScreen,
  AnswersScreen,
  Philosophy
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

    return PageView(
      controller: _pageController,
      onPageChanged: (pageNumber) => pagesModel.setPageInt(pageNumber),
      children: [
        AskScreen(),
        AnswersScreen(),
        PhilosophyScreen(),
      ],
    );
  }
}
