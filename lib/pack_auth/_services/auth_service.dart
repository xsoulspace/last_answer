part of pack_auth;

class AuthService {
  Future<bool> get authorized => SupabaseAuth.instance.hasAccessToken;
}
