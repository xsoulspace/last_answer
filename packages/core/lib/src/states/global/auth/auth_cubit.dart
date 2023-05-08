import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:life_hooks/life_hooks.dart';

import '../../../repositories/repositories.dart';
import '../global.dart';

part 'auth_cubit.freezed.dart';
part 'auth_cubit_states.dart';

class AuthCubitDto {
  AuthCubitDto({required final BuildContext context})
      : repositories = context.read(),
        userNotifier = context.read();
  final RepositoriesCollection repositories;
  final UserNotifier userNotifier;
}

/// The class is required to keep information about user auth status.
final class AuthCubit extends Cubit<AuthCubitState> implements Loadable {
  AuthCubit({
    required this.dto,
  }) : super(const AuthCubitState.unauthorized());
  final AuthCubitDto dto;
  Future<void> onRestoreSession() async {
    // TODO(arenukvern): restore session
    throw UnimplementedError();
  }

  void onSignIn() {
    dto.repositories.user.signIn();
    dto.userNotifier.loadProfile();
    emit(const AuthCubitState.authorized());
  }

  void onSignOut() {
    dto.userNotifier.reset();
    dto.repositories.user.signOut();
    emit(const AuthCubitState.unauthorized());
  }

  @override
  Future<void> onLoad() async {
    await onRestoreSession();
  }
}
