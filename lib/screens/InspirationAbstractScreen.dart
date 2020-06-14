import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:url_launcher/url_launcher.dart';

class InspirationAbstract extends StatefulWidget {
  @override
  _InspirationAbstractState createState() => _InspirationAbstractState();
}

class _InspirationAbstractState extends State<InspirationAbstract> {
//   _launchURL() async {
//   const url = 'mailto:xsoulspace@gmail.com?subject=IIB_Last_Answer	';
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
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
                        child: Text('About Abstract'),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 30),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                'What for?',
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                            ),
                            Flexible(
                                child: Text(
                              'I\'m disigning this app to solve problems complexity and thoughts understanding during project management and just to make easier each other ideas sharing & understanding.',
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
                            SizedBox(
                              width: 100,
                              child: Text(
                                'How?',
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                            ),
                            Flexible(
                                child: Text(
                              'You can use Philosophy Abstract to get ideas how this app can be used and in which techniques.',
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
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Ideas Improvements Bugs?',
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                            ),
                            Flexible(
                                child: SelectableText(
                              'Please leave a message in Google Play, App Store or to xsoulspace@gmail.com. Thank you!',
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
