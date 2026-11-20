# DATA_USER_KNOWLEDGE.md

**Owns:** the user concern — `UserModel`/`UserSettingsModel` (theme, locale,
limits), the locale tables (`locales.dart`, `locale_logic.dart`), user/auth
data sources (local/remote incl. the Serverpod client), the user repository,
and `UserNotifier` (the settings authority the shell reads).

**Key files:** `user_models.dart`, `user_notifier.dart` (persists on every
settings change), `user_repository.dart`, `locales.dart` (`Locales`,
`Languages`), `auth/auth_provider.dart` (the auth contract).

**How to extend:** a new setting = a `UserSettingsModel` field +
`just gen` + the notifier's persist path; sign-in buttons are UI
(`ui_settings/widgets/`), this folder holds the providers. The user
initializers moved to `ui_root` (composition wiring, ADR 0035) —
`UserNotifier.onLoad` takes an `onLocalUserLoad` callback.
