import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';

class StorageService {
  static const String _medicationsKey = 'medications';
  static const String _logsKey = 'medication_logs';
  static const String _currentUserEmailKey = 'current_user_email';

  Future<String> _userPrefix() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserEmailKey) ?? 'guest';
    return email.trim().toLowerCase().replaceAll('@', '_at_').replaceAll('.', '_');
  }

  Future<String> _userKey(String baseKey) async {
    final prefix = await _userPrefix();
    return '${prefix}_$baseKey';
  }

  Future<List<Medication>> getMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _userKey(_medicationsKey));
    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((item) => Medication.fromJson(item)).toList();
  }

  Future<void> saveMedications(List<Medication> medications) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(medications.map((m) => m.toJson()).toList());
    await prefs.setString(await _userKey(_medicationsKey), raw);
  }

  Future<void> addMedication(Medication medication) async {
    final medications = await getMedications();
    medications.add(medication);
    await saveMedications(medications);
  }

  Future<void> updateMedication(Medication medication) async {
    final medications = await getMedications();
    final index = medications.indexWhere((m) => m.id == medication.id);
    if (index >= 0) {
      medications[index] = medication;
      await saveMedications(medications);
    }
  }

  Future<void> deleteMedication(String id) async {
    final medications = await getMedications();
    medications.removeWhere((m) => m.id == id);
    await saveMedications(medications);
  }

  Future<List<MedicationLog>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _userKey(_logsKey));
    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((item) => MedicationLog.fromJson(item)).toList();
  }

  Future<void> addLog(MedicationLog log) async {
    final logs = await getLogs();
    logs.insert(0, log);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _userKey(_logsKey), jsonEncode(logs.map((l) => l.toJson()).toList()));
  }
}
