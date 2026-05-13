import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';

class MedicationCalendarScreen extends StatefulWidget {
  const MedicationCalendarScreen({super.key});

  @override
  State<MedicationCalendarScreen> createState() => _MedicationCalendarScreenState();
}

class _MedicationCalendarScreenState extends State<MedicationCalendarScreen> {
  final StorageService _storage = StorageService();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();
  List<Medication> _medications = [];
  List<MedicationLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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

  bool _isToday(DateTime date) => _sameDay(date, DateTime.now());

  List<Medication> _scheduledFor(DateTime date) {
    return _medications.where((medicine) => medicine.isScheduledOn(date)).toList();
  }

  List<MedicationLog> _logsFor(DateTime date, String medicationId) {
    return _logs.where((log) => log.medicationId == medicationId && _sameDay(log.loggedAt, date)).toList();
  }

  String _statusForDay(DateTime date) {
    final scheduled = _scheduledFor(date);
    if (scheduled.isEmpty) return 'None';

    final hasTaken = scheduled.any((medicine) => _logsFor(date, medicine.id).any((log) => log.status == 'Taken'));
    final hasMissed = scheduled.any((medicine) => _logsFor(date, medicine.id).any((log) => log.status == 'Missed'));

    if (hasTaken) return 'Taken';
    if (hasMissed) return 'Missed';
    if (date.isAfter(DateTime.now())) return 'Future';
    if (_isToday(date)) return 'Pending';
    return 'Missed';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Taken':
        return AppTheme.success;
      case 'Missed':
        return AppTheme.danger;
      case 'Pending':
        return AppTheme.warning;
      case 'Future':
        return AppTheme.textSoft;
      default:
        return Colors.transparent;
    }
  }

  int get _scheduledThisMonth {
    int count = 0;
    final days = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    for (int day = 1; day <= days; day++) {
      if (_scheduledFor(DateTime(_visibleMonth.year, _visibleMonth.month, day)).isNotEmpty) count++;
    }
    return count;
  }

  int get _takenThisMonth {
    return _logs.where((log) => log.status == 'Taken' && log.loggedAt.year == _visibleMonth.year && log.loggedAt.month == _visibleMonth.month).length;
  }

  int get _adherencePercent {
    if (_scheduledThisMonth == 0) return 0;
    final value = ((_takenThisMonth / _scheduledThisMonth) * 100).round();
    return value > 100 ? 100 : value;
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
      _selectedDate = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  String _monthName(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final emptyStartCells = firstDay.weekday % 7;
    final totalCells = emptyStartCells + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemBuilder: (context, index) {
        if (index < emptyStartCells) return const SizedBox.shrink();
        final day = index - emptyStartCells + 1;
        final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
        final status = _statusForDay(date);
        final selected = _sameDay(date, _selectedDate);
        final statusColor = _statusColor(status);

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.white.withOpacity(.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _isToday(date) ? AppTheme.primary : Colors.black12, width: _isToday(date) ? 2 : 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$day', style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : AppTheme.textDark)),
                const SizedBox(height: 5),
                if (status != 'None') Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDateMedicationList() {
    final scheduled = _scheduledFor(_selectedDate);
    if (scheduled.isEmpty) {
      return const Text('No medication scheduled for this day.', style: TextStyle(color: AppTheme.textSoft));
    }

    return Column(
      children: scheduled.map((medicine) {
        final logs = _logsFor(_selectedDate, medicine.id);
        final status = logs.any((log) => log.status == 'Taken')
            ? 'Taken'
            : logs.any((log) => log.status == 'Missed')
                ? 'Missed'
                : _isToday(_selectedDate)
                    ? 'Pending'
                    : _selectedDate.isAfter(DateTime.now())
                        ? 'Future'
                        : 'Missed';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.96), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.border), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 6))]),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: _statusColor(status), child: const Icon(Icons.medication, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${medicine.dosage} • ${medicine.reminderTime}', style: const TextStyle(color: AppTheme.textSoft)),
                    Text('Course: ${medicine.durationDays} days', style: const TextStyle(color: AppTheme.textSoft, fontSize: 12)),
                  ],
                ),
              ),
              Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: _statusColor(status))),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Medication Calendar')),
      body: CareDoseBackground(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 96, 18, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x332B7DE9), blurRadius: 24, offset: Offset(0, 12))]),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.white, size: 38),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Monthly Adherence', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                              Text('$_adherencePercent% medication progress this month', style: TextStyle(color: Colors.white.withOpacity(.88))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
                      Text(_monthName(_visibleMonth), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('S'), Text('M'), Text('T'), Text('W'), Text('T'), Text('F'), Text('S'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildCalendar(),
                  const SizedBox(height: 18),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _LegendDot(color: Colors.green, label: 'Taken'),
                      _LegendDot(color: Colors.red, label: 'Missed'),
                      _LegendDot(color: Colors.orange, label: 'Pending'),
                      _LegendDot(color: Colors.grey, label: 'Future'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Medication for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildSelectedDateMedicationList(),
                ],
              ),
            ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.textSoft)),
      ],
    );
  }
}
