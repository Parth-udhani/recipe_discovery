import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../recipes/domain/entities/recipe.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  factory NotificationService() => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<bool> requestPermission() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return result ?? false;
  }

  Future<void> scheduleMealNotifications({
    Recipe? breakfast,
    Recipe? lunch,
    Recipe? dinner,
  }) async {
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);

    if (breakfast != null) {
      await _scheduleDaily(
        id: 1,
        title: '🌅 Breakfast Time!',
        body: 'How about ${breakfast.name} to start your day?',
        hour: 8,
        minute: 0,
        now: now,
      );
    }

    if (lunch != null) {
      await _scheduleDaily(
        id: 2,
        title: '☀️ Lunch Time!',
        body: 'Try ${lunch.name} for a midday boost!',
        hour: 14,
        minute: 0,
        now: now,
      );
    }

    if (dinner != null) {
      await _scheduleDaily(
        id: 3,
        title: '🌙 Dinner Time!',
        body: 'Tonight\'s suggestion: ${dinner.name}',
        hour: 19,
        minute: 0,
        now: now,
      );
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required tz.TZDateTime now,
  }) async {
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Meal Reminders',
          channelDescription: 'Daily meal recipe suggestions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
