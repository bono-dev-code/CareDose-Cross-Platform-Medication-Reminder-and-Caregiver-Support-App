import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_account.dart';

class AuthService {
  static const String _usersKey = 'auth_users';
  static const String _currentUserEmailKey = 'current_user_email';

  String normalizeEmail(String email) => email.trim().toLowerCase();

  Future<List<UserAccount>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((item) => UserAccount.fromJson(item)).toList();
  }

  Future<void> _saveUsers(List<UserAccount> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final cleanName = fullName.trim();
    final cleanEmail = normalizeEmail(email);

    if (cleanName.length < 2) return 'Please enter your full name.';
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) return 'Please enter a valid email address.';
    if (password.length < 6) return 'Password must be at least 6 characters long.';
    if (password != confirmPassword) return 'Passwords do not match.';

    final users = await getUsers();
    final exists = users.any((user) => normalizeEmail(user.email) == cleanEmail);
    if (exists) return 'An account with this email already exists.';

    final account = UserAccount(
      id: const Uuid().v4(),
      fullName: cleanName,
      email: cleanEmail,
      password: password,
      createdAt: DateTime.now(),
    );

    users.add(account);
    await _saveUsers(users);
    await setCurrentUser(cleanEmail);
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final cleanEmail = normalizeEmail(email);
    final users = await getUsers();

    try {
      final account = users.firstWhere((user) => normalizeEmail(user.email) == cleanEmail);
      if (account.password != password) return 'Incorrect password.';
      await setCurrentUser(account.email);
      return null;
    } catch (_) {
      return 'No account found with this email.';
    }
  }

  Future<void> setCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserEmailKey, normalizeEmail(email));
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserEmailKey);
  }

  Future<UserAccount?> getCurrentUser() async {
    final email = await getCurrentUserEmail();
    if (email == null || email.isEmpty) return null;
    final users = await getUsers();
    try {
      return users.firstWhere((user) => normalizeEmail(user.email) == normalizeEmail(email));
    } catch (_) {
      return null;
    }
  }

  Future<void> updateCurrentUserProfile({required String fullName, required String email}) async {
    final current = await getCurrentUser();
    if (current == null) return;

    final users = await getUsers();
    final cleanEmail = normalizeEmail(email);
    final index = users.indexWhere((user) => user.id == current.id);
    if (index >= 0) {
      users[index] = users[index].copyWith(fullName: fullName.trim(), email: cleanEmail);
      await _saveUsers(users);
      await setCurrentUser(cleanEmail);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
  }
}
