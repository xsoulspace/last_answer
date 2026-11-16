import 'package:lastanswer/common_imports.dart';

class LocaleSwitcherButton extends StatelessWidget {
  const LocaleSwitcherButton({super.key});

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.read<UserNotifier>();
    final locale = context.select<UserNotifier, Locale>(
      (final c) => c.locale.value,
    );
    final language = Languages.values.byName(locale.languageCode);
    final initLocale = namedLocalesMap[language]?.locale ?? Locales.en;
    return LaSelect<Locale>(
      value: initLocale,
      onChanged: (final value) {
        if (value != null) unawaited(userNotifier.updateLocale(value));
      },
      items: namedLocalesMap.values
          .map((final e) => LaSelectItem(value: e.locale, label: e.name))
          .toList(),
    );
  }
}
