import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:last_answer/abstract/NamedLocale.dart';
import 'package:last_answer/shared_utils_models/locales_model.dart';
import 'package:provider/provider.dart';

class LocaleSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleModel>(builder: (context, localeModel, child) {
      return DropdownButton<NamedLocale>(
          isExpanded: true,
          value: localeModel.currentNamedLocale,
          items: LocaleModelConsts.namedLocales.map((namedLocale) {
            return DropdownMenuItem<NamedLocale>(
              key: Key(namedLocale.name),
              value: namedLocale,
              child: Text(
                namedLocale.name,
              ),
            );
          }).toList(),
          onChanged: (NamedLocale? namedLocale) async {
            await localeModel.switchLang(namedLocale?.locale);
          });
    });
  }
}
