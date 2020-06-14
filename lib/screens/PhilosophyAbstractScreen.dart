import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PhilosophyAbstract extends StatefulWidget {
  @override
  _PhilosophyAbstractState createState() => _PhilosophyAbstractState();
}

class _PhilosophyAbstractState extends State<PhilosophyAbstract> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: Text('Philosophy Abstract'),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 30),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'What?',
                              ),
                            ),
                            Flexible(
                                child: SelectableText(
                              'You can use: "Five whys"',
                            )),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Why?',
                              ),
                            ),
                            Flexible(
                                child: SelectableText(
                              'Because, you can use this technique if you have a problem or idea, which needs to be explored more deeply. Method of exploration also often named as "cause and effect" exploration. See more about the technique at wiki: https://en.wikipedia.org/wiki/Five_whys',
                            )),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'What else?',
                              ),
                            ),
                            Flexible(
                                child: SelectableText(
                              'You can use: "PDCA (Plan-Do-Study-Act): Shewhart-Deming cycle"',
                            )),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Why?',
                              ),
                            ),
                            Flexible(
                                child: SelectableText(
                              'Because it most universal technique. It does not solid questions, as in "Five Whys", but the method can help not just make idea exploration, but to understand whole area problems. See more about the technique at wiki:  https://en.wikipedia.org/wiki/PDCA',
                            )),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'What else?',
                              ),
                            ),
                            Flexible(
                                child: SelectableText(
                              'You can use: "Six Sigma"',
                            )),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Why?',
                              ),
                            ),
                            Flexible(
                                child: SelectableText(
                              'Beacuse if your problem or idea has manufacture/transport origin, this method will certanly helps to develop or imporve business process or product. See more about the technique at wiki:  https://en.wikipedia.org/wiki/Six_Sigma',
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
