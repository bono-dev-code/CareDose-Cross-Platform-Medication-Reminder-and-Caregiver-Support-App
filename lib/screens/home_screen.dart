import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../services/auth_service.dart';
import '../services/encouragement_service.dart';
import '../services/storage_service.dart';
import '../services/reminder_service.dart';
import '../utils/app_theme.dart';
import '../widgets/medication_card.dart';
import '../widgets/professional_widgets.dart';
import '../widgets/stat_card.dart';
import 'add_medication_screen.dart';
import 'history_screen.dart';
import 'medication_calendar_screen.dart';
import 'health_insights_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  final AuthService _authService = AuthService();
  final EncouragementService _encouragement = EncouragementService();
  final ReminderService _reminderService = ReminderService();
  List<Medication> _medications = [];
  List<MedicationLog> _logs = [];
  bool _loading = true;
  String _firstName = 'there';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUser();
    final medications = await _storage.getMedications();
    final logs = await _storage.getLogs();
    if (!mounted) return;
    setState(() {
      _medications = medications;
      _logs = logs;
      _firstName = user?.fullName.split(' ').first ?? 'there';
      _loading = false;
    });
  }

  int get _takenToday => _logs.where((log) => log.status == 'Taken' && _isToday(log.loggedAt)).length;
  int get _missedToday => _logs.where((log) => log.status == 'Missed' && _isToday(log.loggedAt)).length;
  int get _activeCount => _medications.length;
  int get _lowRefillCount => _medications.where((m) => m.pillsRemaining <= m.refillAlertAt).length;

  String get _dynamicGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  List<Medication> get _todayMedications {
    final today = DateTime.now();
    final list = _medications.where((m) => m.isScheduledOn(today)).toList();
    list.sort((a, b) => _minutesFromTimeText(a.reminderTime).compareTo(_minutesFromTimeText(b.reminderTime)));
    return list;
  }

  int get _monthlyScheduledDoses {
    final now = DateTime.now();
    int count = 0;
    for (final med in _medications) {
      for (int day = 1; day <= DateTime(now.year, now.month + 1, 0).day; day++) {
        if (med.isScheduledOn(DateTime(now.year, now.month, day))) count++;
      }
    }
    return count;
  }

  int get _monthlyTakenDoses {
    final now = DateTime.now();
    return _logs.where((log) => log.status == 'Taken' && log.loggedAt.year == now.year && log.loggedAt.month == now.month).length;
  }

  int get _adherencePercentage {
    final scheduled = _monthlyScheduledDoses;
    if (scheduled == 0) return 0;
    final percentage = ((_monthlyTakenDoses / scheduled) * 100).round();
    return percentage.clamp(0, 100).toInt();
  }

  int get _currentStreak {
    if (_medications.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    for (int offset = 0; offset < 120; offset++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: offset));
      final scheduled = _medications.where((m) => m.isScheduledOn(day)).length;
      if (scheduled == 0) continue;
      final taken = _logs.where((log) => log.status == 'Taken' && log.loggedAt.year == day.year && log.loggedAt.month == day.month && log.loggedAt.day == day.day).length;
      if (taken >= scheduled) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _minutesFromTimeText(String timeText) {
    final normalized = timeText.trim().toUpperCase();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$').firstMatch(normalized);
    if (match == null) return 9999;
    int hour = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final period = match.group(3);
    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  String _statusForMedicationToday(Medication medication) {
    final todayLogs = _logs.where((log) => log.medicationId == medication.id && _isToday(log.loggedAt)).toList();
    if (todayLogs.any((log) => log.status == 'Taken')) return 'Taken';
    if (todayLogs.any((log) => log.status == 'Missed')) return 'Missed';
    if (todayLogs.any((log) => log.status == 'Skipped')) return 'Skipped';
    if (todayLogs.any((log) => log.status == 'Snoozed')) return 'Snoozed';
    final reminderMinutes = _minutesFromTimeText(medication.reminderTime);
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    return reminderMinutes < nowMinutes ? 'Due now' : 'Upcoming';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<String?> _askForNote(String title) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: CareCard(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                const Text('Optional: add a quick note about side effects, mood, or symptoms.', style: TextStyle(color: AppTheme.textSoft)),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Medication note', prefixIcon: Icon(Icons.edit_note_rounded)),
                ),
                const SizedBox(height: 14),
                ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
                TextButton(onPressed: () => Navigator.pop(context, ''), child: const Text('Continue without note')),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _markMedication(Medication medication, String status) async {
    if (status == 'Taken' && medication.pillsRemaining <= 0) {
      _showMessage('No pills remaining. Please refill before marking as taken.');
      return;
    }

    final note = await _askForNote('Mark ${medication.name} as $status');
    if (note == null) return;

    final log = MedicationLog(
      id: const Uuid().v4(),
      medicationId: medication.id,
      medicationName: medication.name,
      status: status,
      loggedAt: DateTime.now(),
      note: note,
    );
    await _storage.addLog(log);
    if (status == 'Taken') {
      final updated = medication.copyWith(pillsRemaining: medication.pillsRemaining - 1);
      await _storage.updateMedication(updated);
      _showMessage(medication.encouragementEnabled ? 'Medication taken. ${_encouragement.getRandomMessage()}' : 'Medication marked as taken.');
    } else if (status == 'Skipped') {
      _showMessage('Medication skipped for this dose.');
    } else {
      _showMessage('Medication marked as missed.');
    }
    await _loadData();
  }

  Future<void> _snoozeMedication(Medication medication) async {
    final scheduled = await _reminderService.scheduleSnoozeReminder(medication: medication, minutes: 10);
    final log = MedicationLog(
      id: const Uuid().v4(),
      medicationId: medication.id,
      medicationName: medication.name,
      status: 'Snoozed',
      loggedAt: DateTime.now(),
      note: 'Snoozed for 10 minutes',
    );
    await _storage.addLog(log);
    _showMessage(scheduled ? 'Snoozed for 10 minutes.' : 'Snooze saved. Notification needs device permission to ring.');
    await _loadData();
  }

  Future<void> _deleteMedication(Medication medication) async {
    await _storage.deleteMedication(medication.id);
    _showMessage('${medication.name} deleted.');
    await _loadData();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _openAddScreen() async {
    await Navigator.push(context, AppRoutes.fadeSlide(const AddMedicationScreen()));
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('CareDose'),
        actions: [
          IconButton(tooltip: 'Calendar', icon: const Icon(Icons.calendar_month), onPressed: () => Navigator.push(context, AppRoutes.fadeSlide(const MedicationCalendarScreen()))),
          IconButton(tooltip: 'History', icon: const Icon(Icons.history), onPressed: () => Navigator.push(context, AppRoutes.fadeSlide(const HistoryScreen()))),
          IconButton(tooltip: 'Profile', icon: const Icon(Icons.person), onPressed: () => Navigator.push(context, AppRoutes.fadeSlide(const ProfileScreen()))),
        ],
      ),
      body: CareDoseBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 96, 18, 100),
                  children: [
                    AnimatedEntrance(
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Color(0x332B7DE9), blurRadius: 26, offset: Offset(0, 14))]),
                        child: Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$_dynamicGreeting, $_firstName 👋', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white)), const SizedBox(height: 8), Text(_activeCount == 0 ? 'Let us set up your first medication reminder.' : 'You have $_activeCount active medication plan${_activeCount == 1 ? '' : 's'} today.', style: TextStyle(fontSize: 15, height: 1.4, color: Colors.white.withOpacity(.9)))])),
                            Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 38)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Taken Today',
                            value: '$_takenToday',
                            icon: Icons.check_circle,
                            color: AppTheme.success,
                            onTap: () => Navigator.push(
                              context,
                              AppRoutes.fadeSlide(const HistoryScreen(initialFilter: 'Taken', todayOnly: true)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Missed Today',
                            value: '$_missedToday',
                            icon: Icons.warning_amber,
                            color: AppTheme.warning,
                            onTap: () => Navigator.push(
                              context,
                              AppRoutes.fadeSlide(const HistoryScreen(initialFilter: 'Missed', todayOnly: true)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Refill Alerts',
                            value: '$_lowRefillCount',
                            icon: Icons.inventory_2_outlined,
                            color: AppTheme.warning,
                            onTap: () => Navigator.push(context, AppRoutes.fadeSlide(const HealthInsightsScreen())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Health Insights',
                            value: '$_adherencePercentage%',
                            icon: Icons.insights_rounded,
                            color: AppTheme.primary,
                            onTap: () => Navigator.push(context, AppRoutes.fadeSlide(const HealthInsightsScreen())),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CareCard(
                      onTap: () => Navigator.push(context, AppRoutes.fadeSlide(const HealthInsightsScreen())),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedProgressRing(percentage: _adherencePercentage),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Monthly Health Score', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.textDark)),
                                const SizedBox(height: 5),
                                Text('$_currentStreak day streak • $_monthlyTakenDoses doses taken this month', style: const TextStyle(color: AppTheme.textSoft, height: 1.35)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    CareCard(
                      child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.mint, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.calendar_month, color: AppTheme.teal)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Medication Calendar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.textDark)), SizedBox(height: 3), Text('View your monthly taken, missed, and pending doses.', style: TextStyle(color: AppTheme.textSoft))])), IconButton(onPressed: () => Navigator.push(context, AppRoutes.fadeSlide(const MedicationCalendarScreen())), icon: const Icon(Icons.chevron_right))]),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Icon(Icons.timeline, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text('Today\'s Timeline', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_todayMedications.isEmpty)
                      const CareCard(
                        child: Column(
                          children: [
                            Icon(Icons.event_available, color: AppTheme.teal, size: 42),
                            SizedBox(height: 10),
                            Text('No doses scheduled for today.', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                            SizedBox(height: 4),
                            Text('Add a medication plan and CareDose will build your daily timeline automatically.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSoft)),
                          ],
                        ),
                      )
                    else
                      CareCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: _todayMedications.map((medication) {
                            final status = _statusForMedicationToday(medication);
                            final statusColor = status == 'Taken'
                                ? AppTheme.success
                                : status == 'Missed'
                                    ? AppTheme.danger
                                    : status == 'Due now'
                                        ? AppTheme.warning
                                        : AppTheme.primary;
                            final statusIcon = status == 'Taken'
                                ? Icons.check_circle
                                : status == 'Missed'
                                    ? Icons.cancel
                                    : status == 'Due now'
                                        ? Icons.notifications_active
                                        : Icons.schedule;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Container(width: 72, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(16)), child: Text(medication.reminderTime, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark))),
                                  const SizedBox(width: 12),
                                  Container(width: 42, height: 42, decoration: BoxDecoration(color: statusColor.withOpacity(.12), shape: BoxShape.circle), child: Icon(statusIcon, color: statusColor, size: 22)),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(medication.name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark)), const SizedBox(height: 2), Text('${medication.dosage} • $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.w700))])),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Text('Today\'s Medication', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                    const SizedBox(height: 12),
                    if (_medications.isEmpty)
                      const CareCard(
                        child: Column(
                          children: [
                            CareIllustration(size: 130),
                            SizedBox(height: 10),
                            Text('No medication added yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                            SizedBox(height: 6),
                            Text('Tap “Add Medicine” to create your first reminder, calendar schedule, and medication timeline.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSoft, fontSize: 15, height: 1.35)),
                          ],
                        ),
                      )
                    else
                      ..._medications.asMap().entries.map((entry) {
                        final medication = entry.value;
                        return AnimatedEntrance(
                          index: entry.key,
                          child: MedicationCard(
                            medication: medication,
                            onTaken: () => _markMedication(medication, 'Taken'),
                            onMissed: () => _markMedication(medication, 'Missed'),
                            onSnooze: () => _snoozeMedication(medication),
                            onSkip: () => _markMedication(medication, 'Skipped'),
                            onDelete: () => _deleteMedication(medication),
                          ),
                        );
                      }),
                  ],
                ),
              ),
      ),
      floatingActionButton: AnimatedCareFab(onPressed: _openAddScreen),
    );
  }
}
