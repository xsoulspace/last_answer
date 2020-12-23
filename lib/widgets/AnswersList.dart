import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/models/AnswersModel.dart';
import 'package:lastanswer/widgets/AnswerCard.dart';
import 'package:provider/provider.dart';

class AnswersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AnswersModel answersModel = Provider.of<AnswersModel>(context);

    return ListView.builder(
        addSemanticIndexes: true,
        reverse: true,
        itemCount: answersModel.answers.length,
        itemBuilder: (context, index) {
          final answer = answersModel.answersReversed[index];
          return AnswerCard(index, answer);
        });
  }
}
