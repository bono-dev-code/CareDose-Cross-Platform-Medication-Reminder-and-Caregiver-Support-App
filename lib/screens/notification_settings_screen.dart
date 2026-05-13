import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/reminder_service.dart';
import '../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _service = ProfileService();
  final _reminderService = ReminderService();
  bool _reminders = true;
  bool _refill = true;
  bool _encouragement = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _service.getNotificationSettings();
    if (!mounted) return;
    setState(() {
      _reminders = settings['reminders'] ?? true;
      _refill = settings['refill'] ?? true;
      _encouragement = settings['encouragement'] ?? true;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _service.saveNotificationSettings(reminders: _reminders, refill: _refill, encouragement: _encouragement);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings saved.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text('Choose what CareDose should remind you about.', style: TextStyle(color: AppTheme.textSoft, fontSize: 16)),
                const SizedBox(height: 16),
                SwitchListTile(value: _reminders, onChanged: (v) => setState(() => _reminders = v), title: const Text('Medication reminders'), subtitle: const Text('Alert me when it is time to take medicine.')),
                SwitchListTile(value: _refill, onChanged: (v) => setState(() => _refill = v), title: const Text('Refill alerts'), subtitle: const Text('Warn me when pills are running low.')),
                SwitchListTile(value: _encouragement, onChanged: (v) => setState(() => _encouragement = v), title: const Text('Encouragement messages'), subtitle: const Text('Show supportive health motivation.')),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: () async {
                    final sent = await _reminderService.showTestAlarmNotification();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          sent
                              ? 'Test alarm notification sent.'
                              : 'Notifications are not available here. Test on a real Android/iOS device and allow notification permission.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Test Alarm Notification'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save Settings')),
              ],
            ),
    );
  }
}
