class MedicationLog {
  final String id;
  final String medicationId;
  final String medicationName;
  final String status;
  final DateTime loggedAt;
  final String note;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.status,
    required this.loggedAt,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'status': status,
        'loggedAt': loggedAt.toIso8601String(),
        'note': note,
      };

  factory MedicationLog.fromJson(Map<String, dynamic> json) => MedicationLog(
        id: json['id'] ?? '',
        medicationId: json['medicationId'] ?? '',
        medicationName: json['medicationName'] ?? '',
        status: json['status'] ?? 'Taken',
        loggedAt: DateTime.tryParse(json['loggedAt'] ?? '') ?? DateTime.now(),
        note: json['note'] ?? '',
      );
}
