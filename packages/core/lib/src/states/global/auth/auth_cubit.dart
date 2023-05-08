import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core.dart';

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
final class AuthCubit extends Cubit<AuthCubitState> {
  AuthCubit({
    required this.dto,
  }) : super(const AuthCubitState.unauthorized());
  final AuthCubitDto dto;
  void onSignIn() {
    dto.userNotifier.loadProfile();
    dto.repositories.user.signIn();
    emit(const AuthCubitState.authorized());
  }

  void onSignOut() {
    dto.userNotifier.reset();
    dto.repositories.user.signOut();
    emit(const AuthCubitState.unauthorized());
  }
}
