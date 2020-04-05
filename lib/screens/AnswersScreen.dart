import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:howtosolvequest/models/AnswersModel.dart';
import 'package:provider/provider.dart';

class AnswersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Answers'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _AnswersList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var answers = Provider.of<AnswersModel>(context);
    return ListView.builder(
      itemCount: answers.length(),
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.done),
        title: Text(
          answers.answers[index].title,
        ),
      ),
    );
  }
}
