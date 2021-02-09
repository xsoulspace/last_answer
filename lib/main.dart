import 'package:flutter/material.dart';
import 'package:last_answer/screens/Settings.dart';
import 'package:last_answer/widgets/ProjectCard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'IBM Plex Sans',
          brightness: Brightness.dark),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _addNewProject() {
    setState(() {});
  }

  double _screenWidthAdjustment = 200;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidthAdjustment = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    _openSettings() {
      Navigator.of(context).push(PageRouteBuilder(
          fullscreenDialog: true,
          transitionDuration: Duration(milliseconds: 250),
          reverseTransitionDuration: Duration(milliseconds: 250),
          barrierDismissible: true,
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Settings();
          }));
    }

    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Hero(
                    tag: 'appBarBackground',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(color: Theme.of(context).canvasColor),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Hero(
                      tag: 'appBarMenuButton',
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                            icon: Icon(Icons.more_horiz),
                            onPressed: _openSettings),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SafeArea(child: SizedBox(height: 80, child: ProjectCard())),
                Positioned(
                  bottom: 20,
                  right: 29,
                  child: FloatingActionButton(
                    onPressed: _addNewProject,
                    tooltip: 'Add new project',
                    child: Icon(Icons.add),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
