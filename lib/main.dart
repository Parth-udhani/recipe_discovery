import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/favorites/bloc/favorites_cubit.dart';
import 'features/notifications/notification_service.dart';
import 'features/recipes/domain/usecases/recipe_usecases.dart';
import 'features/recipes/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  AppLogger.info('DI container initialised');

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  AppLogger.info('WorkManager initialised');

  await sl<NotificationService>().init();
  AppLogger.info('NotificationService initialised');

  runApp(const RecipeApp());
}

/// Must be a top-level function — called by WorkManager in a background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    await NotificationService().init();
    // Re-schedule next day's meal notifications with cached/static content.
    await NotificationService().scheduleMealNotifications();
    return true;
  });
}

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key});

  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissionsAndSchedule();
  }

  Future<void> _requestPermissionsAndSchedule() async {
    final notifStatus = await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();

    if (!notifStatus.isGranted) {
      AppLogger.warning('Notification permission denied — skipping scheduling');
      return;
    }

    try {
      // Use searchRecipes (ONE API call each, returns full details) instead of
      // getRecipesByCategory which triggers 1 filter + 6 detail calls per meal.
      // Total here: 3 API calls vs the previous 21.
      AppLogger.info('Fetching notification recipes (3 search calls)…');
      final searchUseCase = sl<SearchRecipes>();

      final breakfastResults = await searchUseCase.call('pancakes');
      final lunchResults     = await searchUseCase.call('chicken');
      final dinnerResults    = await searchUseCase.call('salmon');

      await sl<NotificationService>().scheduleMealNotifications(
        breakfast: breakfastResults.isNotEmpty ? breakfastResults.first : null,
        lunch:     lunchResults.isNotEmpty     ? lunchResults.first     : null,
        dinner:    dinnerResults.isNotEmpty    ? dinnerResults.first    : null,
      );

      // Keep notifications alive — re-schedule every 24 h via WorkManager.
      await Workmanager().registerPeriodicTask(
        'mealReminderTask',
        'mealReminderTask',
        frequency: const Duration(hours: 24),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );

      AppLogger.success('Meal notifications scheduled ✓');
    } catch (e) {
      AppLogger.error('Notification scheduling failed', error: e);
      // Non-fatal — app continues normally.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<FavoritesCubit>()..loadFavorites()),
      ],
      child: MaterialApp(
        title: 'Recipe Discovery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}