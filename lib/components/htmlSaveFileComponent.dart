// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:excel/excel.dart';
import 'package:howtosolvethequest/entities/Answer.dart';
import 'package:howtosolvethequest/models/AnswersModel.dart';
import 'package:howtosolvethequest/models/LocaleModel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// import 'package:universal_html/html.dart';
// import 'dart:html' as html;
class HtmlSaveFileComponent {
  final context;

  HtmlSaveFileComponent(this.context);

  saveInWeb() async {
    try {
      var decoder = Excel.createExcel();
      var sheet = 'Sheet1';
      int i = 1;
      AnswersModel answers = Provider.of<AnswersModel>(context, listen: false);
      LocaleModel localeModel =
          Provider.of<LocaleModel>(context, listen: false);

      List answ = answers.answersList;
      for (Answer answer in answ) {
        String cellAddressA = 'A${i.toString()}';
        String cellAddressB = 'B${i.toString()}';

        decoder
          ..updateCell(sheet, CellIndex.indexByString(cellAddressA),
              answer.question.title.getProp(localeModel.current))
          ..updateCell(
              sheet, CellIndex.indexByString(cellAddressB), answer.title);

        i++;
      }
      final blob = Blob([await decoder.encode()]);
      final url = Url.createObjectUrlFromBlob(blob);
      DateTime now = DateTime.now();
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(now);
      final anchor = document.createElement('a') as AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'share$formattedDate.xlsx';
      document.body.children.add(anchor);

      // download
      anchor.click();
    } catch (e) {
      print(e);
    }
  }
}
