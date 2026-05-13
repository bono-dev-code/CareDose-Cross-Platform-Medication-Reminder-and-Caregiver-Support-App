import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../utils/app_theme.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProfileService();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getHealthProfile();
    _ageController.text = data['age'] ?? '';
    _conditionController.text = data['condition'] ?? '';
    _allergiesController.text = data['allergies'] ?? '';
    _emergencyNameController.text = data['emergencyName'] ?? '';
    _emergencyPhoneController.text = data['emergencyPhone'] ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _service.saveHealthProfile(
      age: _ageController.text,
      condition: _conditionController.text,
      allergies: _allergiesController.text,
      emergencyName: _emergencyNameController.text,
      emergencyPhone: _emergencyPhoneController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Health profile saved.')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _conditionController.dispose();
    _allergiesController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Patient Health Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 16),
                  TextFormField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake))),
                  const SizedBox(height: 14),
                  TextFormField(controller: _conditionController, maxLines: 2, decoration: const InputDecoration(labelText: 'Medical condition', prefixIcon: Icon(Icons.health_and_safety))),
                  const SizedBox(height: 14),
                  TextFormField(controller: _allergiesController, maxLines: 2, decoration: const InputDecoration(labelText: 'Allergies', prefixIcon: Icon(Icons.warning_amber))),
                  const SizedBox(height: 14),
                  TextFormField(controller: _emergencyNameController, decoration: const InputDecoration(labelText: 'Emergency contact name', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 14),
                  TextFormField(controller: _emergencyPhoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Emergency contact phone', prefixIcon: Icon(Icons.call))),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save Health Profile')),
                ],
              ),
            ),
    );
  }
}
