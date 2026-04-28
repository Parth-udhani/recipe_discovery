// lib/features/recipes/data/datasources/recipe_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  final Dio dio;
  RecipeRemoteDataSource(this.dio);

  Future<List<RecipeModel>> searchRecipes(String query) async {
    final response =
    await dio.get(AppConstants.searchUrl, queryParameters: {'s': query});
    final meals = response.data['meals'] as List?;
    AppLogger.debug('searchRecipes "$query" → ${meals?.length ?? 0} results');
    if (meals == null) return [];
    return meals.map((m) => RecipeModel.fromJson(m)).toList();
  }

  Future<List<RecipeModel>> getRecipesByCategory(String category) =>
      _fetchByFilter({'c': category});

  Future<List<RecipeModel>> getRecipesByArea(String area) =>
      _fetchByFilter({'a': area});

  Future<RecipeModel?> getRecipeDetail(String id) async {
    final response =
    await dio.get(AppConstants.lookupUrl, queryParameters: {'i': id});
    final meals = response.data['meals'] as List?;
    if (meals == null || meals.isEmpty) return null;
    return RecipeModel.fromJson(meals.first);
  }

  // ── Private ────────────────────────────────────────────────────────────────

  // Category and area filters return identical shallow payloads — only the
  // query param differs. This helper deduplicates that logic.
  Future<List<RecipeModel>> _fetchByFilter(
      Map<String, String> queryParams) async {
    final response = await dio.get(AppConstants.filterUrl,
        queryParameters: queryParams);
    final meals = response.data['meals'] as List?;
    if (meals == null) return [];

    // Filter endpoint only returns id / name / thumb, so we fetch full details.
    final detailed = await Future.wait(
      meals.take(10).map((m) => getRecipeDetail(m['idMeal'] as String)),
    );
    return detailed.whereType<RecipeModel>().toList();
  }
}