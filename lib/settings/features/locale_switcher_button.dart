import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/idea/widgets/question_dropdown.dart';

class LocaleSwitcherButton extends StatelessWidget {
  const LocaleSwitcherButton({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.read<UserNotifier>();
    final locale =
        context.select<UserNotifier, Locale>((final c) => c.locale.value);
    final language = Languages.values.byName(locale.languageCode);
    final initLocale = namedLocalesMap[language]?.locale ?? Locales.en;
    return DropdownMenu<Locale>(
      menuStyle: defaultDropdownMenuStyle,
      textStyle: context.textTheme.bodyMedium,
      inputDecorationTheme: defaultDropdownMenuInputTheme,
      initialSelection: initLocale,
      onSelected: userNotifier.updateLocale,
      dropdownMenuEntries: namedLocalesMap.values
          .map(
            (final e) => DropdownMenuEntry(
              value: e.locale,
              label: e.name,
            ),
          )
          .toList(),
    );
  }
}
