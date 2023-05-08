import 'package:flutter/widgets.dart';

import '../../../../core.dart';

final class UserNotifier extends ValueNotifier<UserModel> {
  UserNotifier({
    required this.repositories,
  }) : super(UserModel.empty);
  final RepositoriesCollection repositories;
  UserRepository get _userRepository => repositories.user;
  void loadProfile() {}
  void reset() {
    value = UserModel.empty;
  }
}
