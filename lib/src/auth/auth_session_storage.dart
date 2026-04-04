import "package:shared_preferences/shared_preferences.dart";

import "auth_models.dart";

class AuthSessionStorage {
  static const String _storageKey = "auth_session";

  Future<AuthSession?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? rawSession = preferences.getString(_storageKey);

    if (rawSession == null || rawSession.isEmpty) {
      return null;
    }

    return AuthSession.fromStorage(rawSession);
  }

  Future<void> write(AuthSession session) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, session.toStorage());
  }

  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
