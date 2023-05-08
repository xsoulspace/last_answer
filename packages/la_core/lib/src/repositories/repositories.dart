import 'package:flutter/widgets.dart';

import 'implementations/implementations.dart';

export 'implementations/implementations.dart';

@immutable
final class RepositoriesCollection {
  const RepositoriesCollection({
    required this.user,
  });
  final UserRepository user;
}
