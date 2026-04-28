import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/bloc/favorites_cubit.dart';
import 'features/notifications/notification_service.dart';

import 'features/recipes/domain/usecases/recipe_usecases.dart';
import 'features/recipes/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init dependency injection (also inits Hive inside)
  await di.init();


  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  // Init notifications
  await sl<NotificationService>().init();



  runApp(const RecipeApp());
}// ✅ MUST be top-level (outside main)

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final service = NotificationService();

    await service.init();

    await service.scheduleMealNotifications(
      breakfast: null,
      lunch: null,
      dinner: null,
    );

    return Future.value(true);
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

    // Request notification permission
    final notifStatus = await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
    if (notifStatus.isGranted) {
      // Fetch a recipe to suggest for each meal time
      try {
        final usecase = sl<GetRecipesByCategory>();
        final breakfast = await usecase.call('Breakfast');
        final lunch = await usecase.call('Chicken');
        final dinner = await usecase.call('Seafood');

        await sl<NotificationService>().scheduleMealNotifications(
          breakfast: breakfast.isNotEmpty ? breakfast.first : null,
          lunch: lunch.isNotEmpty ? lunch.first : null,
          dinner: dinner.isNotEmpty ? dinner.first : null,
        );
        await Workmanager().registerPeriodicTask(
          "mealReminderTask",
          "mealReminderTask",
          frequency: const Duration(hours: 6),
          existingWorkPolicy: ExistingWorkPolicy.replace, // 🔥 important
        );
      } catch (_) {
        // Notifications are best-effort; don't crash
      }
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