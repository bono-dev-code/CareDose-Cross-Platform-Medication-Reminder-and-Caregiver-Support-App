import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _supportsLocalNotifications {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  Future<bool> initialize() async {
    if (_initialized) return true;
    if (!_supportsLocalNotifications) return false;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      await _requestPermissions();
      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('CareDose notification initialization failed: $e');
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
        await androidPlugin?.requestExactAlarmsPermission();
      }

      if (Platform.isIOS) {
        final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (e) {
      debugPrint('CareDose notification permission request failed: $e');
    }
  }

  NotificationDetails _alarmNotificationDetails() {
    const android = AndroidNotificationDetails(
      'caredose_medication_alarm_channel',
      'Medication Alarm Reminders',
      channelDescription: 'Alarm-style reminders for scheduled medication times.',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
      ticker: 'CareDose medication reminder',
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('taken_action', 'TAKEN', showsUserInterface: true),
        AndroidNotificationAction('snooze_action', 'SNOOZE 10 MIN', showsUserInterface: true),
        AndroidNotificationAction('skip_action', 'SKIP', showsUserInterface: true),
      ],
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return const NotificationDetails(android: android, iOS: ios);
  }

  int _notificationId(String medicationId, int dayIndex) {
    final base = medicationId.hashCode.abs() % 100000;
    return base + dayIndex;
  }

  tz.TZDateTime _scheduledDate(DateTime day, TimeOfDay time) {
    return tz.TZDateTime(
      tz.local,
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
    );
  }

  Future<bool> scheduleMedicationReminder({
    required Medication medication,
    required TimeOfDay reminderTime,
  }) async {
    final ready = await initialize();
    if (!ready) return false;

    try {
      await cancelMedicationReminder(medication.id);

      final start = DateTime(medication.startDate.year, medication.startDate.month, medication.startDate.day);
      final now = tz.TZDateTime.now(tz.local);

      for (int i = 0; i < medication.durationDays && i < 366; i++) {
        final day = start.add(Duration(days: i));
        final scheduled = _scheduledDate(day, reminderTime);

        if (scheduled.isBefore(now)) continue;

        await _notifications.zonedSchedule(
          _notificationId(medication.id, i),
          'CareDose Reminder',
          'It is time to take ${medication.name} (${medication.dosage}).',
          scheduled,
          _alarmNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: medication.id,
        );
      }
      return true;
    } catch (e) {
      debugPrint('CareDose schedule reminder failed: $e');
      return false;
    }
  }

  Future<void> cancelMedicationReminder(String medicationId) async {
    final ready = await initialize();
    if (!ready) return;

    try {
      for (int i = 0; i <= 366; i++) {
        await _notifications.cancel(_notificationId(medicationId, i));
      }
    } catch (e) {
      debugPrint('CareDose cancel reminder failed: $e');
    }
  }


  Future<bool> scheduleSnoozeReminder({
    required Medication medication,
    int minutes = 10,
  }) async {
    final ready = await initialize();
    if (!ready) return false;

    try {
      final scheduled = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
      await _notifications.zonedSchedule(
        _notificationId(medication.id, 900),
        'CareDose Snooze Reminder',
        'Snooze ended: take ${medication.name} (${medication.dosage}).',
        scheduled,
        _alarmNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: medication.id,
      );
      return true;
    } catch (e) {
      debugPrint('CareDose snooze reminder failed: $e');
      return false;
    }
  }

  Future<bool> showTestAlarmNotification() async {
    final ready = await initialize();
    if (!ready) return false;

    try {
      await _notifications.show(
        777001,
        'CareDose Test Alarm',
        'This is how your medication reminder will appear.',
        _alarmNotificationDetails(),
      );
      return true;
    } catch (e) {
      debugPrint('CareDose test alarm failed: $e');
      return false;
    }
  }

  String buildReminderMessage(String medicationName, String time) {
    return 'Reminder: It is time to take $medicationName at $time.';
  }
}
