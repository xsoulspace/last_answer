

import 'dart:html';

import 'package:excel/excel.dart';
import 'package:howtosolvethequest/entities/Answer.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:provider/provider.dart';
// import 'package:universal_html/html.dart';
// import 'dart:html' as html;
class HtmlSaveFileComponent{
  final context;
  HtmlSaveFileComponent(this.context);
  saveInWeb() async {
      var decoder = Excel.createExcel();
      var sheet = 'Sheet1';
      int i = 1;
      var answers = Provider.of<AnswersModel>(context);
      List answ = answers.answersList;
      for (Answer answer in answ) {
        String cellAddressA = 'A${i.toString()}';
        String cellAddressB = 'B${i.toString()}';
        String cellAddressC = 'C${i.toString()}';

        decoder
          ..updateCell(sheet, CellIndex.indexByString(cellAddressA),
              answer.question.title.ru)
          ..updateCell(sheet, CellIndex.indexByString(cellAddressB),
              answer.question.title.en)
          ..updateCell(
              sheet, CellIndex.indexByString(cellAddressC), answer.title,
              verticalAlign: VerticalAlign.Top);

        i++;
      }
      final blob = Blob([await decoder.encode()]);
      final url = Url.createObjectUrlFromBlob(blob);
      final anchor = document.createElement('a') as AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'some_name.xlsx';
      document.body.children.add(anchor);

      // download
      anchor.click();
    }
}
