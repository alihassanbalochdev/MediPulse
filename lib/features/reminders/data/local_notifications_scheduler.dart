import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medipulse_medical/features/medications/domain/dose_schedule.dart';
import 'package:medipulse_medical/features/medications/domain/medication.dart';
import 'package:medipulse_medical/features/reminders/domain/reminder_scheduler.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;
  Future<void> _queue = Future.value();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'dose_reminders',
      'Dose reminders',
      channelDescription: 'Reminders to take your medicines',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> _init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> replaceAll(List<ScheduledDose> doses) {
    // One call at a time, so quick edits can't interleave cancel and schedule
    _queue = _queue.then((_) => _replace(doses)).catchError((Object error) {
      debugPrint('Could not schedule reminders: $error');
    });
    return _queue;
  }

  Future<void> _replace(List<ScheduledDose> doses) async {
    await (_ready ??= _init());
    await _plugin.cancelAll();

    for (final (:medication, :time) in doses) {
      await _plugin.zonedSchedule(
        id: _idFor(medication, time),
        title: 'Time for ${medication.name}',
        body: '${medication.dosage} · ${medication.form.label}',
        // The same instant, expressed in UTC. No local timezone lookup needed.
        scheduledDate: tz.TZDateTime.from(time, tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  // Android needs a 32-bit int id; mask keeps it positive
  int _idFor(Medication medication, DateTime time) =>
      Object.hash(medication.id, time.millisecondsSinceEpoch) & 0x7fffffff;
}