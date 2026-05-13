import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication_log.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/professional_widgets.dart';

class HistoryScreen extends StatefulWidget {
  final String initialFilter;
  final bool todayOnly;

  const HistoryScreen({
    super.key,
    this.initialFilter = 'All',
    this.todayOnly = false,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storage = StorageService();
  List<MedicationLog> _logs = [];
  bool _loading = true;
  late String _selectedFilter;
  late bool _todayOnly;

  final List<String> _filters = const ['All', 'Taken', 'Missed', 'Skipped', 'Snoozed', 'Pending'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _todayOnly = widget.todayOnly;
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _storage.getLogs();
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  List<MedicationLog> get _filteredLogs {
    return _logs.where((log) {
      final statusMatches = _selectedFilter == 'All' || log.status.toLowerCase() == _selectedFilter.toLowerCase();
      final dateMatches = !_todayOnly || _isToday(log.loggedAt);
      return statusMatches && dateMatches;
    }).toList();
  }

  String get _titleText {
    if (_selectedFilter == 'Taken' && _todayOnly) return 'Taken Today';
    if (_selectedFilter == 'Missed' && _todayOnly) return 'Missed Today';
    if (_todayOnly) return 'Today\'s History';
    return 'Medication History';
  }

  String get _emptyMessage {
    if (_selectedFilter == 'Taken' && _todayOnly) return 'No medication has been marked as taken today.';
    if (_selectedFilter == 'Missed' && _todayOnly) return 'No missed medication has been recorded today.';
    if (_selectedFilter == 'Pending') return 'Pending doses appear on the dashboard timeline before they are marked.';
    return 'No medication history found for this filter.';
  }

  Color _statusColor(String status) {
    if (status == 'Taken') return AppTheme.success;
    if (status == 'Missed') return AppTheme.danger;
    if (status == 'Skipped') return AppTheme.textSoft;
    if (status == 'Snoozed') return AppTheme.primary;
    return AppTheme.warning;
  }

  IconData _statusIcon(String status) {
    if (status == 'Taken') return Icons.check_circle;
    if (status == 'Missed') return Icons.cancel;
    if (status == 'Skipped') return Icons.skip_next_rounded;
    if (status == 'Snoozed') return Icons.snooze_rounded;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _filteredLogs;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(_titleText)),
      body: CareDoseBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 96, 18, 28),
                children: [
                  AnimatedEntrance(
                    child: CareCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: (_selectedFilter == 'Missed' ? AppTheme.warning : AppTheme.primary).withOpacity(.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  _selectedFilter == 'Missed' ? Icons.warning_amber : Icons.history,
                                  color: _selectedFilter == 'Missed' ? AppTheme.warning : AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_titleText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                                    const SizedBox(height: 3),
                                    Text(
                                      _todayOnly ? 'Showing only today\'s $_selectedFilter records.' : 'Review all medication records.',
                                      style: const TextStyle(color: AppTheme.textSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _filters.map((filter) {
                              final selected = _selectedFilter == filter;
                              return ChoiceChip(
                                label: Text(filter),
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedFilter = filter),
                                selectedColor: AppTheme.primary.withOpacity(.14),
                                labelStyle: TextStyle(
                                  color: selected ? AppTheme.primary : AppTheme.textSoft,
                                  fontWeight: FontWeight.w800,
                                ),
                                side: BorderSide(color: selected ? AppTheme.primary.withOpacity(.35) : AppTheme.border),
                                backgroundColor: Colors.white,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Switch(
                                value: _todayOnly,
                                onChanged: (value) => setState(() => _todayOnly = value),
                              ),
                              const Text('Today only', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredLogs.isEmpty)
                    AnimatedEntrance(
                      index: 1,
                      child: CareCard(
                        child: Column(
                          children: [
                            Icon(_selectedFilter == 'Missed' ? Icons.sentiment_satisfied_alt : Icons.event_note, color: AppTheme.teal, size: 48),
                            const SizedBox(height: 12),
                            Text(_emptyMessage, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSoft, fontSize: 16, height: 1.35)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredLogs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final log = entry.value;
                      final color = _statusColor(log.status);
                      return AnimatedEntrance(
                        index: index + 1,
                        child: CareCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(18)),
                                child: Icon(_statusIcon(log.status), color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log.medicationName, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDark, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(DateFormat('EEE, dd MMM yyyy • HH:mm').format(log.loggedAt), style: const TextStyle(color: AppTheme.textSoft)),
                                    if (log.note.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text('Note: ${log.note}', style: const TextStyle(color: AppTheme.textSoft, fontStyle: FontStyle.italic)),
                                    ],
                                  ],
                                ),
                              ),
                              PillBadge(icon: _statusIcon(log.status), text: log.status, color: color),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
      ),
    );
  }
}
