import "package:shared_preferences/shared_preferences.dart";

import "personal_prayer_models.dart";

class PersonalPrayerStorage {
  const PersonalPrayerStorage();

  static const String _storagePrefix = "personal_prayer_snapshot";

  Future<PersonalPrayerSnapshot> read(String userId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_storageKey(userId));

    if (raw == null || raw.isEmpty) {
      return PersonalPrayerSnapshot.empty();
    }

    return PersonalPrayerSnapshot.fromStorage(raw);
  }

  Future<void> write(String userId, PersonalPrayerSnapshot snapshot) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey(userId), snapshot.toStorage());
  }

  String _storageKey(String userId) => "${_storagePrefix}_$userId";
}
