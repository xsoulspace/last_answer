import 'package:flutter/widgets.dart';

import '../../../../la_core.dart';

final class UserNotifier extends ValueNotifier<UserModel> {
  UserNotifier({
    required this.repositoriesCollection,
  }) : super(UserModel.empty);
  final RepositoriesCollection repositoriesCollection;
  UserRepository get _userRepository => repositoriesCollection.user;
  void loadProfile() {}
  void reset() {
    value = UserModel.empty;
  }
}
