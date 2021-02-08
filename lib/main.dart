import 'package:flutter/material.dart';
import 'package:last_answer/screens/QuestionsAnswers.dart';

import 'abstract/Project.dart';

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
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // body: ListView.builder(itemBuilder: (BuildContext context, int index) {
      //   return ListTile();
      // }),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 80,
              child: GestureDetector(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'back',
                        child: Container(color: Colors.white),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Hero(
                                    tag: 'title',
                                    child: Material(
                                        color: Colors.transparent,
                                        child: Text('hello'))),
                                Hero(
                                    tag: 'check',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Checkbox(
                                          value: true,
                                          onChanged: (bool? value) {
                                            print(value);
                                          }),
                                    ))
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                      fullscreenDialog: true,
                      transitionDuration: Duration(milliseconds: 150),
                      transitionsBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                          Widget child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return QuestionsAnswers(
                            project: Project(id: 0, title: ''));
                      }));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProject,
        tooltip: 'Add new project',
        child: Icon(Icons.add),
      ),
    );
  }
}
