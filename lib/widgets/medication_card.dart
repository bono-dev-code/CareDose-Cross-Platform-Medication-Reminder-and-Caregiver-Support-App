import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../utils/app_theme.dart';
import 'professional_widgets.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTaken;
  final VoidCallback onMissed;
  final VoidCallback onSnooze;
  final VoidCallback onSkip;
  final VoidCallback onDelete;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onTaken,
    required this.onMissed,
    required this.onSnooze,
    required this.onSkip,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock = medication.pillsRemaining <= medication.refillAlertAt;

    return PressableScale(
      child: CareCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(gradient: AppTheme.softHeroGradient, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.medication_rounded, color: AppTheme.primary, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medication.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -0.2)),
                      const SizedBox(height: 5),
                      Text('${medication.dosage} • ${medication.reminderTime}', style: const TextStyle(color: AppTheme.textSoft, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete medication',
                  onPressed: onDelete,
                  icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textSoft),
                ),
              ],
            ),
            if (medication.instructions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(medication.instructions, style: const TextStyle(color: AppTheme.textSoft, height: 1.45, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PillBadge(icon: Icons.category_outlined, text: medication.category, color: AppTheme.primary),
                PillBadge(icon: Icons.inventory_2_outlined, text: lowStock ? 'Refill soon: ${medication.pillsRemaining} left' : '${medication.pillsRemaining} pills left', color: lowStock ? AppTheme.warning : AppTheme.success),
                PillBadge(icon: Icons.calendar_month_rounded, text: '${medication.durationDays} days', color: AppTheme.teal),
              ],
            ),
            if (lowStock) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.warning.withOpacity(.10), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.notification_important_outlined, color: AppTheme.warning),
                    SizedBox(width: 8),
                    Expanded(child: Text('Refill reminder: this medication is running low.', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w800))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ElevatedButton.icon(onPressed: onTaken, icon: const Icon(Icons.check_rounded), label: const Text('Taken'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(onPressed: onSnooze, icon: const Icon(Icons.snooze_rounded), label: const Text('Snooze'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: onMissed, icon: const Icon(Icons.close_rounded), label: const Text('Missed'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger))),
                const SizedBox(width: 10),
                Expanded(child: TextButton.icon(onPressed: onSkip, icon: const Icon(Icons.skip_next_rounded), label: const Text('Skip'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
