import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lastanswer/abstract/basic_project.dart';
import 'package:lastanswer/abstract/current_state_keys.dart';
import 'package:lastanswer/widgets/answer_card.dart';
import 'package:lastanswer/widgets/new_answer_field.dart';

class QuestionsAnswers extends StatefulWidget {
  final Project project;
  const QuestionsAnswers({
    required this.project,
  });
  @override
  _QuestionsAnswersState createState() => _QuestionsAnswersState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Project>('project', project));
  }
}

class _QuestionsAnswersState extends State<QuestionsAnswers> {
  final _titleEditingController = TextEditingController();
  @override
  Widget build(final BuildContext context) {
    _titleEditingController.text = widget.project.title;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        leading: IconButton(
          color: Theme.of(context).textTheme.headline6?.color,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        title: Hero(
          tag: 'title${widget.project.id}',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _titleEditingController,
              onChanged: (final newText) async {
                final project = widget.project;
                project.title = newText;
                await project.save();
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Hero(
              tag: 'check${widget.project.id}',
              child: Material(
                color: Colors.transparent,
                child: ValueListenableBuilder(
                  builder: (_, box, __) {
                    return Checkbox(
                      value: widget.project.isCompleted,
                      onChanged: (value) async {
                        final project = widget.project;
                        project.isCompleted = value ?? false;
                        await project.save();
                      },
                    );
                  },
                  valueListenable:
                      Hive.box<Project>(HiveBoxes.projects).listenable(),
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable:
                          Hive.box<Project>(HiveBoxes.projects).listenable(),
                      builder: (_, final __, final child) {
                        final answers = widget.project.answers ?? [];
                        answers.sort((final a, final b) =>
                            a.created.compareTo(b.created));
                        final reversedAnswers = answers.reversed;
                        const divider = Divider(
                          height: 1.5,
                          thickness: 0.15,
                        );
                        return ListView.separated(
                          separatorBuilder: (context, final index) => divider,
                          reverse: true,
                          itemCount: reversedAnswers.length,
                          itemBuilder: (context, index) {
                            final answer = reversedAnswers.elementAt(index);
                            if (answer.id == BoxAnswer.currentAnswer) {
                              return Container(
                                key: Key(index.toString()),
                              );
                            }
                            return AnswerCard(
                              key: Key(answer.id),
                              index: index,
                              answer: answer,
                              onDismissed: () async {
                                await answer.delete();
                                setState(() {});
                              },
                              confirmDelete: () async {
                                return showDialog<bool>(
                                  context: context,
                                  builder: (final context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)
                                              ?.areYouSure ??
                                          ''),
                                      content: Text(
                                          " '${answer.title}' ${AppLocalizations.of(context)?.answerWillBeLost}"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                    ?.cancel ??
                                                '',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                    ?.delete ??
                                                '',
                                            style: TextStyle(
                                                color: Colors.red[800]),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  NewAnswerField(project: widget.project)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}