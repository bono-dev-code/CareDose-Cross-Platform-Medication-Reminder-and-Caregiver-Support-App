class Medication {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final String category;
  final String reminderTime;
  final int pillsRemaining;
  final int refillAlertAt;
  final bool encouragementEnabled;
  final DateTime createdAt;
  final DateTime startDate;
  final int durationDays;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    this.category = 'General',
    required this.reminderTime,
    required this.pillsRemaining,
    required this.refillAlertAt,
    required this.encouragementEnabled,
    required this.createdAt,
    DateTime? startDate,
    this.durationDays = 30,
  }) : startDate = startDate ?? createdAt;

  DateTime get endDate => DateTime(startDate.year, startDate.month, startDate.day).add(Duration(days: durationDays - 1));

  bool isScheduledOn(DateTime date) {
    final selected = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !selected.isBefore(start) && !selected.isAfter(end);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'instructions': instructions,
        'category': category,
        'reminderTime': reminderTime,
        'pillsRemaining': pillsRemaining,
        'refillAlertAt': refillAlertAt,
        'encouragementEnabled': encouragementEnabled,
        'createdAt': createdAt.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'durationDays': durationDays,
      };

  factory Medication.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      instructions: json['instructions'] ?? '',
      category: json['category'] ?? 'General',
      reminderTime: json['reminderTime'] ?? '',
      pillsRemaining: json['pillsRemaining'] ?? 0,
      refillAlertAt: json['refillAlertAt'] ?? 3,
      encouragementEnabled: json['encouragementEnabled'] ?? false,
      createdAt: created,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? created,
      durationDays: json['durationDays'] ?? 30,
    );
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? instructions,
    String? category,
    String? reminderTime,
    int? pillsRemaining,
    int? refillAlertAt,
    bool? encouragementEnabled,
    DateTime? createdAt,
    DateTime? startDate,
    int? durationDays,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      reminderTime: reminderTime ?? this.reminderTime,
      pillsRemaining: pillsRemaining ?? this.pillsRemaining,
      refillAlertAt: refillAlertAt ?? this.refillAlertAt,
      encouragementEnabled: encouragementEnabled ?? this.encouragementEnabled,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
    );
  }
}
