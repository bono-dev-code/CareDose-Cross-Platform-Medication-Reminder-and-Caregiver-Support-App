import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';

class HealthInsightsScreen extends StatefulWidget {
  const HealthInsightsScreen({super.key});

  @override
  State<HealthInsightsScreen> createState() => _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends State<HealthInsightsScreen> {
  final StorageService _storage = StorageService();
  List<Medication> _medications = [];
  List<MedicationLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final medications = await _storage.getMedications();
    final logs = await _storage.getLogs();
    if (!mounted) return;
    setState(() {
      _medications = medications;
      _logs = logs;
      _loading = false;
    });
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  int get _takenThisMonth {
    final now = DateTime.now();
    return _logs.where((l) => l.status == 'Taken' && l.loggedAt.year == now.year && l.loggedAt.month == now.month).length;
  }

  int get _missedThisMonth {
    final now = DateTime.now();
    return _logs.where((l) => l.status == 'Missed' && l.loggedAt.year == now.year && l.loggedAt.month == now.month).length;
  }

  int get _scheduledThisMonth {
    final now = DateTime.now();
    int count = 0;
    final days = DateTime(now.year, now.month + 1, 0).day;
    for (final med in _medications) {
      for (int day = 1; day <= days; day++) {
        if (med.isScheduledOn(DateTime(now.year, now.month, day))) count++;
      }
    }
    return count;
  }

  int get _adherence {
    if (_scheduledThisMonth == 0) return 0;
    return ((_takenThisMonth / _scheduledThisMonth) * 100).round().clamp(0, 100).toInt();
  }

  int get _streak {
    if (_medications.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    for (int offset = 0; offset < 90; offset++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: offset));
      final scheduled = _medications.where((m) => m.isScheduledOn(day)).length;
      if (scheduled == 0) continue;
      final taken = _logs.where((l) => l.status == 'Taken' && _sameDay(l.loggedAt, day)).length;
      if (taken >= scheduled) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get _lowRefills => _medications.where((m) => m.pillsRemaining <= m.refillAlertAt).length;

  List<int> get _lastSevenTaken {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
      return _logs.where((l) => l.status == 'Taken' && _sameDay(l.loggedAt, day)).length;
    });
  }

  String get _monthName => DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final bars = _lastSevenTaken;
    final maxBar = bars.isEmpty ? 1 : bars.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Health Insights')),
      body: CareDoseBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 96, 18, 28),
                children: [
                  AnimatedEntrance(
                    child: CareCard(
                      child: Row(
                        children: [
                          AnimatedProgressRing(percentage: _adherence, size: 92, color: AppTheme.success),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_monthName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                                const SizedBox(height: 6),
                                Text('$_takenThisMonth of $_scheduledThisMonth scheduled doses taken this month.', style: const TextStyle(color: AppTheme.textSoft, height: 1.35)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _InsightMiniCard(title: 'Streak', value: '$_streak days', icon: Icons.local_fire_department_rounded, color: AppTheme.warning)),
                      const SizedBox(width: 12),
                      Expanded(child: _InsightMiniCard(title: 'Missed', value: '$_missedThisMonth', icon: Icons.warning_amber_rounded, color: AppTheme.danger)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _InsightMiniCard(title: 'Refill alerts', value: '$_lowRefills', icon: Icons.inventory_2_outlined, color: AppTheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _InsightMiniCard(title: 'Active meds', value: '${_medications.length}', icon: Icons.medication_rounded, color: AppTheme.teal)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  CareCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last 7 Days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                        const SizedBox(height: 16),
                        // Extra height prevents the tallest 100% bar from overflowing on wide screens.
                        SizedBox(
                          height: 178,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 6),
                            child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (index) {
                              final value = bars[index];
                              // Keep the tallest bar inside the available chart area.
                              final height = 28 + (value / maxBar) * 86;
                              final day = DateTime.now().subtract(Duration(days: 6 - index));
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: height),
                                        duration: Duration(milliseconds: 500 + index * 80),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, animatedHeight, _) => Container(
                                          height: animatedHeight,
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.heroGradient,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(DateFormat('E').format(day), style: const TextStyle(fontSize: 12, color: AppTheme.textSoft, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_medications.where((m) => m.pillsRemaining <= m.refillAlertAt).isEmpty)
                    const CareCard(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: AppTheme.success, size: 42),
                          SizedBox(height: 8),
                          Text('No refill warnings right now.', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                          SizedBox(height: 4),
                          Text('CareDose will warn you when medication stock is low.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSoft)),
                        ],
                      ),
                    )
                  else
                    ..._medications.where((m) => m.pillsRemaining <= m.refillAlertAt).map((m) => CareCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.notification_important_outlined, color: AppTheme.warning),
                              const SizedBox(width: 12),
                              Expanded(child: Text('${m.name} is low: ${m.pillsRemaining} pills left.', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark))),
                            ],
                          ),
                        )),
                ],
              ),
      ),
    );
  }
}

class _InsightMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InsightMiniCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
          Text(title, style: const TextStyle(color: AppTheme.textSoft, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
