import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/answer.dart';
import 'package:lastanswer/abstract/hive_boxes.dart';
import 'package:lastanswer/abstract/project.dart';
import 'package:lastanswer/abstract/question.dart';
import 'package:lastanswer/models/questions_model.dart';
import 'package:lastanswer/shared_utils_models/locales_model.dart';
import 'package:lastanswer/utils/uuid.dart';
import 'package:lastanswer/widgets/share_button.dart';
import 'package:provider/provider.dart';

class NewAnswerField extends StatefulWidget {
  final Project project;
  const NewAnswerField({
    required this.project,
  });
  @override
  _NewAnswerFieldState createState() => _NewAnswerFieldState();
}

class _NewAnswerFieldState extends State<NewAnswerField> {
  final TextEditingController _titleController = TextEditingController();
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String questionId = QuestionsModelConsts.questions[5].id;

  Future<void> updateCurrentAnswer(
      {required Box<Answer> box, required String title}) async {
    await box.put(
        BoxAnswer.currentAnswer,
        Answer(
            created: DateTime.now(),
            title: title,
            questionId: questionId,
            id: BoxAnswer.currentAnswer,
            positionIndex: 0));
  }

  Future<void> clear({required Box<Answer> box}) async {
    _titleController.text = '';
    updateCurrentAnswer(
      box: box,
      title: '',
    );
  }

  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final _answerBox = Hive.box<Answer>(HiveBoxes.answers);
    int maxIndexedAnswer = _answerBox.values.isEmpty
        ? 0
        : _answerBox.values.reduce((value, el) {
              final valueIndex = value.positionIndex;
              final elIndex = el.positionIndex;
              if (valueIndex == null || elIndex == null) return value;
              if (valueIndex > elIndex) return el;
              return value;
            }).positionIndex ??
            0;

    Future<void> createAnswer() async {
      if (_titleController.text
          .replaceAll(RegExp(' '), "")
          .replaceAll("\n", "")
          .isEmpty) return;
      final newAnswer = Answer(
        title: _titleController.text,
        questionId: questionId,
        id: uuid.v1(),
        created: DateTime.now(),
        positionIndex: maxIndexedAnswer++,
      );
      clear(box: _answerBox);

      final answers =
          widget.project.answers ?? HiveList(_answerBox, objects: []);
      await _answerBox.put(newAnswer.id, newAnswer);
      answers.add(newAnswer);
      widget.project.answers = answers;
      await widget.project.save();
    }

    final questionsModel = Provider.of<QuestionsModel>(context);

    // loading state if its exists
    if (_titleController.text.isEmpty) {
      final _answer = _answerBox.get(BoxAnswer.currentAnswer);
      _titleController.text = _answer?.title ?? '';
      if (_answer != null) {
        setState(() {
          questionId = _answer.questionId;
        });
      }
    }
    final question = questionsModel.getById(questionId);
    final questoinIndex = questionsModel.getIndexById(questionId);

    return Material(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 2),
            SizedBox(
              height: 60,
              child: Row(children: [
                Expanded(
                  child: QuestionsSlider(
                      question: question,
                      questionIndex: questoinIndex,
                      onSelected: (int? index) async {
                        if (index == null) return;
                        final newQuestion =
                            questionsModel.questions.elementAt(index.toInt());
                        setState(() {
                          questionId = newQuestion.id;
                          updateCurrentAnswer(
                            box: _answerBox,
                            title: _titleController.text,
                          );
                        });
                      }),
                ),
                const SizedBox(width: 8),
                ShareButton(
                  project: widget.project,
                ),
              ]),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: focusNode,
                    onKey: (RawKeyEvent event) {
                      if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
                          !event.isShiftPressed) {
                        createAnswer();
                      }
                    },
                    child: TextFormField(
                      onFieldSubmitted: (String newText) async =>
                          createAnswer(),
                      controller: _titleController,
                      minLines: 1,
                      maxLines: 7,
                      keyboardType: TextInputType.multiline,
                      onChanged: (text) async {
                        await updateCurrentAnswer(box: _answerBox, title: text);
                      },
                      decoration: InputDecoration(
                          // labelStyle: TextStyle(color: Colors.white),
                          // fillColor: ThemeColors.lightAccent,
                          // focusedBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(
                          //     color: ThemeColors.lightAccent ?? Colors.white,
                          //   ),
                          // ),
                          // border: OutlineInputBorder(
                          //     borderSide: BorderSide(
                          //         color: ThemeColors.lightAccent ?? Colors.white)),
                          labelText: AppLocalizations.of(context)?.answer),
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: createAnswer,
                    icon: Icon(
                      Icons.arrow_circle_up,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class QuestionsSlider extends StatefulWidget {
  final void Function(int? index) onSelected;
  final Question question;
  final int questionIndex;
  const QuestionsSlider({
    required this.onSelected,
    required this.question,
    required this.questionIndex,
  });
  @override
  _QuestionsSliderState createState() => _QuestionsSliderState();
}

class _QuestionsSliderState extends State<QuestionsSlider> {
  late final PageController _pageController;
  void updateSelected() {
    widget.onSelected(_pageController.page?.toInt());
  }

  @override
  void initState() {
    _pageController = PageController(
        viewportFraction: 0.25, initialPage: widget.questionIndex);
    _pageController.addListener(updateSelected);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(updateSelected);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsModel = Provider.of<QuestionsModel>(context);

    return Center(
      child: PageView.builder(
        controller: _pageController,
        itemCount: questionsModel.length,
        clipBehavior: Clip.antiAlias,
        itemBuilder: (context, index) => AnimatedBuilder(
            animation: _pageController,
            builder: (BuildContext _, Widget? __) => _builder(
                  index: index,
                  questionsModel: questionsModel,
                )),
      ),
    );
  }

  Widget _builder({
    required int index,
    required QuestionsModel questionsModel,
  }) {
    final question = questionsModel.questions.elementAt(index);
    final isSelected = question.id == widget.question.id;
    final text = Consumer<LocaleModel>(builder: (context, locale, child) {
      return Text(
        question.title.getProp(locale.currentNamedLocale.localeCode),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: isSelected ? 18.5 : 14),
      );
    });
    if (question.id == widget.question.id) {
      return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ),
        ),
        onPressed: () {},
        child: text,
      );
    }
    return TextButton(
      onPressed: () {
        _pageController.jumpToPage(index);
        widget.onSelected(index);
      },
      child: text,
    );
  }
}
