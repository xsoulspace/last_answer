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
                                'How?',
                              ),
                            ),
                            Flexible(
                                child: Text(
                              'You can use: "Five Why"',
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
                                child: Text(
                              'Because this technique...',
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
                                'How?',
                              ),
                            ),
                            Flexible(
                                child: Text(
                              'You can use: "Why–because analysis"',
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
                                child: Text(
                              'Because this technique...',
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
                                'How?',
                              ),
                            ),
                            Flexible(
                                child: Text(
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
                                child: Text(
                              'Because this technique...',
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
                                'How?',
                              ),
                            ),
                            Flexible(
                                child: Text(
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
                                child: Text(
                              'Because this technique...',
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
