import 'package:flutter/material.dart';
import 'package:howtosolvequest/components/QuestionsComponent.dart';
import 'package:howtosolvequest/entities/Question.dart';
import 'package:howtosolvequest/models/AnswersModel.dart';
import 'package:howtosolvequest/models/QuestionsModel.dart';
import 'package:provider/provider.dart';

class AskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var answers = Provider.of<AnswersModel>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Last answer'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/menu');
              },
              icon: Icon(Icons.done),
              tooltip: 'complete',
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/answers');
              },
              child: Text('Answers'),
            ),
          ],
        ),
        body: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(answers.lastAnswer.title),
                ),
                QuestionsComponent(),
                QuestionsAndInput()
              ],
            )));
  }
}

class QuestionsAndInput extends StatefulWidget {
  _QuestionsAndInput createState() => _QuestionsAndInput();
}

class _QuestionsAndInput extends State<QuestionsAndInput> {
  String inputText;
  Question question = Question('', 0);
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var answers = Provider.of<AnswersModel>(context);
    var questions = Provider.of<QuestionsModel>(context);

    return Column(
      children: <Widget>[
        SizedBox(height: 30),
        Divider(),
        SizedBox(height: 10),
        Container(
            height: 40.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: questions.length(),
              itemBuilder: (context, index) => Container(
                  width: 100.0,
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        question = questions.questions[index];
                      });
                    },
                    child: Text(
                      questions.questions[index].title,
                    ),
                  )),
            )),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(question.title),
            IconButton(
              onPressed: () {
                answers.add(inputText, question);
                _controller.clear();
              },
              icon: Icon(Icons.send),
            ),
          ],
        ),
        SizedBox(height: 30),
        Center(
          child: TextFormField(
            controller: _controller,
            autofocus: true,
            minLines: 1,
            maxLines: 7,
            keyboardType: TextInputType.multiline,
            onChanged: (text) {
              inputText = text;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: 'Answer...'),
          ),
        )
      ],
    );
  }
}
