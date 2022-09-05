import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:provider/provider.dart' as provider_lib;
import 'package:supabase_flutter/supabase_flutter.dart';

UsersNotifier createUsersNotifier(final BuildContext context) => UsersNotifier(
      supabaseClient: context.read(),
      usersApi: context.read(),
    );

class UsersNotifier extends ChangeNotifier implements Loadable {
  UsersNotifier({
    required this.usersApi,
    required this.supabaseClient,
  });
  final UsersApi usersApi;
  final SupabaseClient supabaseClient;
  final currentUser = ValueNotifier(UserModel.zero);
  final authenticated = ValueNotifier(false);
  @override
  Future<void> onLoad() async {
    await onAuthChange();
    authenticated.addListener(onAuthChange);
  }

  Future<void> onAuthChange() async {
    if (authenticated.value) {
      final id = supabaseClient.auth.currentUser?.id;
      if (id == null) {
        authenticated.value = false;
      } else {
        final user = await usersApi.getById(id);
        currentUser.value = user!;
      }
    } else {
      currentUser.value = UserModel.zero;
    }
  }

  @override
  void dispose() {
    currentUser.dispose();
    authenticated.dispose();
    super.dispose();
  }
}
