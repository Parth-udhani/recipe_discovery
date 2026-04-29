// lib/features/recipes/data/datasources/recipe_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  final Dio dio;
  RecipeRemoteDataSource(this.dio);

  /// Full-text search — returns complete recipe objects in a single API call.
  Future<List<RecipeModel>> searchRecipes(String query) async {
    AppLogger.request('GET', 'search?s=$query');
    final response =
    await dio.get(AppConstants.searchUrl, queryParameters: {'s': query});
    final meals = response.data['meals'] as List?;
    AppLogger.response(response.statusCode ?? 200, 'search?s=$query',
        count: meals?.length ?? 0);
    if (meals == null) return [];
    return meals.map((m) => RecipeModel.fromJson(m)).toList();
  }

  Future<List<RecipeModel>> getRecipesByCategory(String category) =>
      _fetchByFilter({'c': category}, label: 'category=$category');

  Future<List<RecipeModel>> getRecipesByArea(String area) =>
      _fetchByFilter({'a': area}, label: 'area=$area');

  Future<RecipeModel?> getRecipeDetail(String id) async {
    AppLogger.request('GET', 'lookup?i=$id');
    final response =
    await dio.get(AppConstants.lookupUrl, queryParameters: {'i': id});
    final meals = response.data['meals'] as List?;
    if (meals == null || meals.isEmpty) return null;
    final model = RecipeModel.fromJson(meals.first);
    AppLogger.response(response.statusCode ?? 200, 'lookup?i=$id');
    return model;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  /// Category and area filters return shallow payloads (id/name/thumb only).
  /// We fetch full details for the top [_pageSize] results in parallel.
  ///
  /// Keeping [_pageSize] = 6 matches the 2-column grid and cuts detail calls
  /// from 10 → 6 per load (saves 4 round-trips every time).
  static const int _pageSize = 6;

  Future<List<RecipeModel>> _fetchByFilter(
      Map<String, String> queryParams, {
        required String label,
      }) async {
    AppLogger.request('GET', 'filter?$label');
    final response = await dio.get(AppConstants.filterUrl,
        queryParameters: queryParams);
    final meals = response.data['meals'] as List?;
    if (meals == null) return [];

    AppLogger.response(response.statusCode ?? 200, 'filter?$label',
        count: meals.length);

    // Fetch full details for the first [_pageSize] results in parallel.
    final slice = meals.take(_pageSize).toList();
    AppLogger.info('Fetching details for ${slice.length} recipes…');
    final detailed = await Future.wait(
      slice.map((m) => getRecipeDetail(m['idMeal'] as String)),
    );
    final results = detailed.whereType<RecipeModel>().toList();
    AppLogger.success('Loaded ${results.length} full recipes for $label');
    return results;
  }
}