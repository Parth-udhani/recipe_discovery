import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../recipes/domain/entities/recipe.dart';
import '../../core/utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // Shared channel details — defined once, reused everywhere.
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
    AppLogger.info('NotificationService initialised');
  }

  // ── Production: schedule at fixed meal times each day ─────────────────────

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

    AppLogger.info('Meal notifications scheduled');
  }

  // ── Testing: fires notifications in 5 / 10 / 15 seconds ──────────────────
  //
  // Call this from a debug button (e.g. in HomePage) to instantly verify that
  // notifications are delivered without waiting for 8 AM / 2 PM / 7 PM.
  //
  //   await sl<NotificationService>().scheduleTestNotifications(
  //     breakfast: breakfastRecipe,
  //     lunch: lunchRecipe,
  //     dinner: dinnerRecipe,
  //   );

  Future<void> scheduleTestNotifications({
    Recipe? breakfast,
    Recipe? lunch,
    Recipe? dinner,
  }) async {
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);

    final meals = [
      (
      id: 1,
      title: '🌅 [TEST] Breakfast',
      body: 'Try ${breakfast?.name ?? "a recipe"} to start your day!',
      delay: 900,
      ),
      (
      id: 2,
      title: '☀️ [TEST] Lunch',
      body: 'How about ${lunch?.name ?? "a recipe"} for lunch!',
      delay: 1200,
      ),
      (
      id: 3,
      title: '🌙 [TEST] Dinner',
      body: 'Tonight: ${dinner?.name ?? "a recipe"}!',
      delay: 1800,
      ),
    ];

    for (final m in meals) {
      final scheduled = now.add(Duration(seconds: m.delay));
      await _plugin.zonedSchedule(
        m.id,
        m.title,
        m.body,
        scheduled,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("NOW: ${tz.TZDateTime.now(tz.local)}");
      print("SCHEDULED: $scheduled");
      AppLogger.debug('Scheduling at: $scheduled');
      AppLogger.debug('Test notification #${m.id} in ${m.delay}s');
    }

    AppLogger.info('Test notifications scheduled (5 / 10 / 15 seconds)');
  }

  // ── Private helper ─────────────────────────────────────────────────────────

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

    // If the time has already passed today, push to tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 🔥 DAILY repeat
      // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}