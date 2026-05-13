import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../utils/app_theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _service = ProfileService();
  bool _appLock = false;
  bool _hideSensitive = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _service.getPrivacySettings();
    if (!mounted) return;
    setState(() {
      _appLock = settings['appLock'] ?? false;
      _hideSensitive = settings['hideSensitive'] ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _service.savePrivacySettings(appLock: _appLock, hideSensitive: _hideSensitive);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy settings saved.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and Security')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: const Text('CareDose stores this starter project data locally on your device using SharedPreferences.', style: TextStyle(color: AppTheme.textSoft)),
                ),
                const SizedBox(height: 16),
                SwitchListTile(value: _appLock, onChanged: (v) => setState(() => _appLock = v), title: const Text('App lock placeholder'), subtitle: const Text('UI setting saved now. Biometric lock can be connected later.')),
                SwitchListTile(value: _hideSensitive, onChanged: (v) => setState(() => _hideSensitive = v), title: const Text('Hide sensitive health details'), subtitle: const Text('Save user preference for privacy display.')),
                const SizedBox(height: 22),
                ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save Privacy Settings')),
              ],
            ),
    );
  }
}
