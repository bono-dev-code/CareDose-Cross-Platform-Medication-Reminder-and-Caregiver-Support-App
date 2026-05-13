import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medication.dart';
import '../services/storage_service.dart';
import '../services/reminder_service.dart';
import '../utils/app_theme.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _pillsController = TextEditingController(text: '30');
  String _selectedCategory = 'General';
  final List<String> _categories = const ['General', 'Diabetes', 'Blood Pressure', 'Antibiotics', 'Vitamins', 'Pain Relief', 'Mental Health'];
  final _refillController = TextEditingController(text: '3');
  final _durationController = TextEditingController(text: '30');
  final StorageService _storage = StorageService();
  final ReminderService _reminderService = ReminderService();

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  DateTime _selectedStartDate = DateTime.now();
  bool _encouragementEnabled = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _pillsController.dispose();
    _refillController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _selectedStartDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final medication = Medication(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      instructions: _instructionsController.text.trim(),
      category: _selectedCategory,
      reminderTime: _selectedTime.format(context),
      pillsRemaining: int.tryParse(_pillsController.text.trim()) ?? 0,
      refillAlertAt: int.tryParse(_refillController.text.trim()) ?? 3,
      encouragementEnabled: _encouragementEnabled,
      createdAt: DateTime.now(),
      startDate: _selectedStartDate,
      durationDays: int.tryParse(_durationController.text.trim()) ?? 30,
    );

    await _storage.addMedication(medication);
    final notificationScheduled = await _reminderService.scheduleMedicationReminder(
      medication: medication,
      reminderTime: _selectedTime,
    );

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificationScheduled
              ? 'Medication saved and alarm reminder scheduled.'
              : 'Medication saved. Notifications need a real Android/iOS device and permission to work.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? _numberRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Medication Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              validator: _required,
              decoration: const InputDecoration(labelText: 'Medicine name', prefixIcon: Icon(Icons.medication)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dosageController,
              validator: _required,
              decoration: const InputDecoration(labelText: 'Dosage e.g. 1 tablet', prefixIcon: Icon(Icons.local_pharmacy)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Instructions e.g. Take after food', prefixIcon: Icon(Icons.notes)),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Medication category', prefixIcon: Icon(Icons.category_outlined)),
              items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value ?? 'General'),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Reminder time', prefixIcon: Icon(Icons.alarm)),
                child: Text(_selectedTime.format(context), style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickStartDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Start date', prefixIcon: Icon(Icons.calendar_today)),
                child: Text(_formatDate(_selectedStartDate), style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _durationController,
              validator: _numberRequired,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration in days e.g. 30', prefixIcon: Icon(Icons.date_range)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pillsController,
              validator: _numberRequired,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pills remaining', prefixIcon: Icon(Icons.inventory_2)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _refillController,
              validator: _numberRequired,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Refill alert when pills reach', prefixIcon: Icon(Icons.notification_important)),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: _encouragementEnabled,
              onChanged: (value) => setState(() => _encouragementEnabled = value),
              title: const Text('Encouragement Mode'),
              subtitle: const Text('Show uplifting messages after medication is taken.'),
              activeThumbColor: AppTheme.primary,
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _saving ? null : _saveMedication,
              icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
