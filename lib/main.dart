import 'package:flutter/material.dart';
import 'package:howtosolvequest/localizations/MainLocalizations.dart';
import 'package:howtosolvequest/models/AnswersModel.dart';
import 'package:howtosolvequest/models/QuestionsModel.dart';
import 'package:howtosolvequest/screens/AnswersScreen.dart';
import 'package:howtosolvequest/screens/AskScreen.dart';
import 'package:howtosolvequest/screens/MenuScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(HowToSolveQuest());

class HowToSolveQuest extends StatefulWidget {
  @override
  _HowToSolveQuestState createState() => _HowToSolveQuestState();
}

class _HowToSolveQuestState extends State<HowToSolveQuest> {
  MainLocalizationsDelegate _localeOverrideDelegate =
      MainLocalizationsDelegate(Locale('en', 'US'));
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AnswersModel()),
        ChangeNotifierProvider(create: (context) => QuestionsModel()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          _localeOverrideDelegate
        ],
        supportedLocales: [
          const Locale('en', 'EN'), // English
          const Locale('ru', 'RU'), // Russian
        ],
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AskScreen(),
          '/menu': (context) => MenuScreen(),
          '/answers': (context) => AnswersScreen(),
        },
      ),
    );
  }
}
