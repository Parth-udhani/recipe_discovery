import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  final Dio dio;

  RecipeRemoteDataSource(this.dio);

  Future<List<RecipeModel>> searchRecipes(String query) async {
    final response = await dio.get(
      AppConstants.searchUrl,
      queryParameters: {'s': query},
    );
    final meals = response.data['meals'] as List?;
    if (meals == null) return [];
    return meals.map((m) => RecipeModel.fromJson(m)).toList();
  }

  Future<List<RecipeModel>> getRecipesByCategory(String category) async {
    final response = await dio.get(
      AppConstants.filterUrl,
      queryParameters: {'c': category},
    );
    final meals = response.data['meals'] as List?;
    if (meals == null) return [];
    // Filter endpoint only returns id/name/thumb — fetch details for first 10
    final limited = meals.take(10).toList();
    final detailedRecipes = await Future.wait(
      limited.map((m) => getRecipeDetail(m['idMeal'])),
    );
    return detailedRecipes.whereType<RecipeModel>().toList();
  }

  Future<List<RecipeModel>> getRecipesByArea(String area) async {
    final response = await dio.get(
      AppConstants.filterUrl,
      queryParameters: {'a': area},
    );
    final meals = response.data['meals'] as List?;
    if (meals == null) return [];
    final limited = meals.take(10).toList();
    final detailedRecipes = await Future.wait(
      limited.map((m) => getRecipeDetail(m['idMeal'])),
    );
    return detailedRecipes.whereType<RecipeModel>().toList();
  }

  Future<RecipeModel?> getRecipeDetail(String id) async {
    final response = await dio.get(
      AppConstants.lookupUrl,
      queryParameters: {'i': id},
    );
    final meals = response.data['meals'] as List?;
    if (meals == null || meals.isEmpty) return null;
    return RecipeModel.fromJson(meals.first);
  }
}