/// The user data concern: user/settings models and locale tables, user +
/// auth data sources, the user repository, the user notifier and its
/// initializers, and the auth providers. See DATA_USER_KNOWLEDGE.md.
library;

export 'auth/auth.dart';
export 'data_sources/interfaces/auth.dart';
export 'data_sources/interfaces/dictionaries.dart';
export 'data_sources/interfaces/user.dart';
export 'data_sources/local/dictionaries.dart';
export 'data_sources/local/user.dart';
export 'data_sources/remote/auth.dart';
export 'data_sources/remote/serverpod_client.dart';
export 'data_sources/remote/user.dart';
export 'locales.dart';
export 'user_models.dart';
export 'user_notifier.dart';
export 'user_repository.dart';
