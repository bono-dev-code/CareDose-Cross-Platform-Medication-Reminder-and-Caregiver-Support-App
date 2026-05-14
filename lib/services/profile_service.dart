import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _authService = AuthService();
  static const String _nameKey = 'profile_name';
  static const String _emailKey = 'profile_email';
  static const String _ageKey = 'health_age';
  static const String _conditionKey = 'health_condition';
  static const String _allergiesKey = 'health_allergies';
  static const String _emergencyNameKey = 'emergency_name';
  static const String _emergencyPhoneKey = 'emergency_phone';
  static const String _remindersKey = 'setting_reminders';
  static const String _refillKey = 'setting_refill_alerts';
  static const String _encouragementKey = 'setting_encouragement';
  static const String _privacyLockKey = 'privacy_lock';
  static const String _hideSensitiveKey = 'privacy_hide_sensitive';

  Future<String> _userPrefix() async {
    final email = await _authService.getCurrentUserEmail();
    return (email ?? 'guest').trim().toLowerCase().replaceAll('@', '_at_').replaceAll('.', '_');
  }

  Future<String> _userKey(String baseKey) async {
    final prefix = await _userPrefix();
    return '${prefix}_$baseKey';
  }

  Future<String> getName() async {
    final user = await _authService.getCurrentUser();
    return user?.fullName ?? 'CareDose User';
  }

  Future<String> getEmail() async {
    final user = await _authService.getCurrentUser();
    return user?.email ?? 'caredose.user@email.com';
  }

  Future<void> saveProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _userKey(_nameKey), name.trim());
    await prefs.setString(await _userKey(_emailKey), email.trim());
    await _authService.updateCurrentUserProfile(fullName: name, email: email);
  }

  Future<Map<String, String>> getHealthProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'age': prefs.getString(await _userKey(_ageKey)) ?? '',
      'condition': prefs.getString(await _userKey(_conditionKey)) ?? '',
      'allergies': prefs.getString(await _userKey(_allergiesKey)) ?? '',
      'emergencyName': prefs.getString(await _userKey(_emergencyNameKey)) ?? '',
      'emergencyPhone': prefs.getString(await _userKey(_emergencyPhoneKey)) ?? '',
    };
  }

  Future<void> saveHealthProfile({
    required String age,
    required String condition,
    required String allergies,
    required String emergencyName,
    required String emergencyPhone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _userKey(_ageKey), age.trim());
    await prefs.setString(await _userKey(_conditionKey), condition.trim());
    await prefs.setString(await _userKey(_allergiesKey), allergies.trim());
    await prefs.setString(await _userKey(_emergencyNameKey), emergencyName.trim());
    await prefs.setString(await _userKey(_emergencyPhoneKey), emergencyPhone.trim());
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'reminders': prefs.getBool(await _userKey(_remindersKey)) ?? true,
      'refill': prefs.getBool(await _userKey(_refillKey)) ?? true,
      'encouragement': prefs.getBool(await _userKey(_encouragementKey)) ?? true,
    };
  }

  Future<void> saveNotificationSettings({
    required bool reminders,
    required bool refill,
    required bool encouragement,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(await _userKey(_remindersKey), reminders);
    await prefs.setBool(await _userKey(_refillKey), refill);
    await prefs.setBool(await _userKey(_encouragementKey), encouragement);
  }

  Future<Map<String, bool>> getPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'appLock': prefs.getBool(await _userKey(_privacyLockKey)) ?? false,
      'hideSensitive': prefs.getBool(await _userKey(_hideSensitiveKey)) ?? false,
    };
  }

  Future<void> savePrivacySettings({required bool appLock, required bool hideSensitive}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(await _userKey(_privacyLockKey), appLock);
    await prefs.setBool(await _userKey(_hideSensitiveKey), hideSensitive);
  }
}
