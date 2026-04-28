import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/recipes/domain/usecases/recipe_usecases.dart';
import '../network/connectivity_service.dart';
import '../../features/recipes/data/datasources/recipe_remote_datasource.dart';
import '../../features/recipes/data/datasources/recipe_local_datasource.dart';
import '../../features/recipes/data/datasources/location_service.dart';
import '../../features/recipes/data/models/recipe_model.dart';
import '../../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../../features/recipes/domain/repositories/recipe_repository.dart';

import '../../features/recipes/presentation/bloc/recipe_cubit.dart';
import '../../features/favorites/hive/favorite_recipe_hive.dart';
import '../../features/favorites/bloc/favorites_cubit.dart';
import '../../features/notifications/notification_service.dart';
import '../constants/app_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(RecipeModelAdapter());

  final cachedBox = await Hive.openBox<RecipeModel>(AppConstants.cachedRecipesBox);
  final favoritesBox = await Hive.openBox<RecipeModel>(AppConstants.favoritesBox);

  // Core
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    return dio;
  });

  // Data sources
  sl.registerLazySingleton<RecipeRemoteDataSource>(
          () => RecipeRemoteDataSource(sl()));
  sl.registerLazySingleton<RecipeLocalDataSource>(
          () => RecipeLocalDataSource(cachedBox));
  sl.registerLazySingleton<FavoriteRecipeHive>(
          () => FavoriteRecipeHive(favoritesBox));

  // Repository
  sl.registerLazySingleton<RecipeRepository>(() => RecipeRepositoryImpl(
    remote: sl(),
    local: sl(),
    connectivity: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetRecipesByCategory(sl()));
  sl.registerLazySingleton(() => GetRecipesByArea(sl()));
  sl.registerLazySingleton(() => SearchRecipes(sl()));

  // Cubits
  sl.registerFactory(() => RecipeCubit(
    getRecipesByCategory: sl(),
    getRecipesByArea: sl(),
    searchRecipes: sl(),
    repository: sl(),
  ));
  sl.registerFactory(() => FavoritesCubit(sl()));
}