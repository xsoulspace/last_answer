import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PhilosophyScreen extends StatefulWidget {
  @override
  _PhilosophyScreenState createState() => _PhilosophyScreenState();
}

class _PhilosophyScreenState extends State<PhilosophyScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox.expand(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: PageView(
                    children: [
                      InspirationAbstract(),
                      PhilosophyAbstract()
                    ],
                  )
                  
                  
                  ))),
    );
  }
}

class PhilosophyAbstract extends StatefulWidget {
  @override
  _PhilosophyAbstractState createState() => _PhilosophyAbstractState();
}

class _PhilosophyAbstractState extends State<PhilosophyAbstract> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class InspirationAbstract extends StatefulWidget {
  @override
  _InspirationAbstractState createState() => _InspirationAbstractState();
}

class _InspirationAbstractState extends State<InspirationAbstract> {
  @override
  Widget build(BuildContext context) {
    return Column(
                    children: <Widget>[
                      Container(
                        child: Center(
                          child: Text('Inspiration Abstract'),
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
                                  'What for?',
                                ),
                              ),
                              Flexible(
                                  child: Text(
                                'I purposed this app to solve problems complexity and thoughts understanding during project management with my collegues and just to make better each other understanding.',
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
                                  'What for?',
                                ),
                              ),
                              Flexible(
                                  child: Text(
                                'I purposed this app to solve problems complexity and thoughts understanding during project management with my collegues and just to make better each other understanding.',
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
                              Flexible(
                                child: Text(
                                  'The reason, why app was build and inspired, because of whish to solve problems complexity and to make a tool, which will allows to make better each other understanding.',
                                ),
                              ),
                              Flexible(
                                  child: Text(
                                'Because of this, for any suggetions, bugs and improvements please leave a message in Google Play, App Store or to xsoulspace@gmail.com. Thank you!',
                              )),
                            ],
                          ),
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [Text('Five Why')],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [Text('Why–because analysis')],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [Text('Six Sigma')],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text('PDCA (Plan-Do-Study-Act): Shewhart-Deming cycle')
                      //   ],
                      // ),
                    ],
                  );
  }
}
