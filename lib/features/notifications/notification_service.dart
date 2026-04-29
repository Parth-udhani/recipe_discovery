import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../recipes/domain/entities/recipe.dart';
import '../../core/utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'meal_reminders',
      'Meal Reminders',
      channelDescription: 'Daily meal recipe suggestions',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    tz.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName.identifier));
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );
  }

  /// Schedule (or re-schedule) daily meal notifications.
  /// Passing null for a meal silently skips that slot.
  Future<void> scheduleMealNotifications({
    Recipe? breakfast,
    Recipe? lunch,
    Recipe? dinner,
  }) async {
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);

    if (breakfast != null) {
      await _scheduleDaily(1, '🌅 Breakfast Time!',
          'How about ${breakfast.name} to start your day?', 8, 0, now);
    }
    if (lunch != null) {
      await _scheduleDaily(2, '☀️ Lunch Time!',
          'Try ${lunch.name} for a midday boost!', 14, 0, now);
    }
    if (dinner != null) {
      await _scheduleDaily(3, '🌙 Dinner Time!',
          "Tonight's suggestion: ${dinner.name}", 19, 0, now);
    }

    AppLogger.success('Meal notifications scheduled');
  }

  // ── Dev / testing helper ──────────────────────────────────────────────────

  /// Fires test notifications in 15 / 20 / 25 seconds.
  /// Wrap calls in `if (kDebugMode)` at the call site.
  Future<void> scheduleTestNotifications({
    Recipe? breakfast,
    Recipe? lunch,
    Recipe? dinner,
  }) async {
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);

    final meals = [
      (id: 1, title: '🌅 [TEST] Breakfast',
      body: 'Try ${breakfast?.name ?? "a recipe"} to start your day!', delay: 15),
      (id: 2, title: '☀️ [TEST] Lunch',
      body: 'How about ${lunch?.name ?? "a recipe"} for lunch!', delay: 20),
      (id: 3, title: '🌙 [TEST] Dinner',
      body: 'Tonight: ${dinner?.name ?? "a recipe"}!', delay: 25),
    ];

    for (final m in meals) {
      final scheduled = now.add(Duration(seconds: m.delay));
      await _plugin.zonedSchedule(
        m.id, m.title, m.body, scheduled, _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      AppLogger.debug('Test notification #${m.id} → fires in ${m.delay}s');
    }

    AppLogger.success('Test notifications scheduled (15 / 20 / 25 s)');
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _scheduleDaily(
      int id,
      String title,
      String body,
      int hour,
      int minute,
      tz.TZDateTime now,
      ) async {
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id, title, body, scheduled, _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    AppLogger.debug('Notification #$id scheduled → ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")} daily');
  }
}