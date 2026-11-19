/// Localized strings for the embedded browser window.
///
/// Kept in the browser's own file (EN/RU/IT) so the window's wording can
/// ship without touching the shared l10n generation, which another actor
/// owns. The selection follows the app locale.
library;

import 'package:flutter/widgets.dart';

/// The browser window's strings in the three shipped locales.
final class BrowserStrings {
  const BrowserStrings(this.locale);

  /// Builds the strings for the current app locale.
  factory BrowserStrings.of(BuildContext context) =>
      BrowserStrings(Localizations.localeOf(context).languageCode);

  final String locale;

  String _choose(String en, String it, String ru) => switch (locale) {
    'it' => it,
    'ru' => ru,
    _ => en,
  };

  /// The address field's placeholder.
  String get addressHint => _choose(
    'Address (http or https)',
    'Indirizzo (http o https)',
    'Адрес (http или https)',
  );

  /// The title of the window.
  String get windowTitle => _choose('Browser', 'Browser', 'Браузер');

  /// Label of the back control.
  String get back => _choose('Back', 'Indietro', 'Назад');

  /// Label of the forward control.
  String get forward => _choose('Forward', 'Avanti', 'Вперёд');

  /// Label of the reload control.
  String get reload => _choose('Reload', 'Ricarica', 'Обновить');

  /// Label of the go control.
  String get go => _choose('Go', 'Vai', 'Открыть');

  /// Label of the close control.
  String get close => _choose('Close', 'Chiudi', 'Закрыть');

  /// Message shown when the typed address is refused.
  String get unsupportedAddress => _choose(
    'Only http and https addresses are opened.',
    'Si aprono solo indirizzi http e https.',
    'Открываются только адреса http и https.',
  );

  /// Message shown when the typed address cannot be parsed.
  String get malformedAddress => _choose(
    'That is not a valid address.',
    'Questo non è un indirizzo valido.',
    'Это не корректный адрес.',
  );

  /// Message shown when the page fails to load.
  String get loadFailed => _choose(
    'The page did not load.',
    'La pagina non è stata caricata.',
    'Страница не загрузилась.',
  );
}
